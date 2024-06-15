//
//  NFCManager.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/06/09.
//

import Foundation
import CoreNFC

class NFCManager: NSObject, NFCNDEFReaderSessionDelegate, ObservableObject {
    private var readerSession: NFCNDEFReaderSession?
    
    @Published var errorMessage: String? = nil
    @Published var processSuccess: Bool = false
    
    var location: EventLocation = .nagoya

    
    struct NFCDataModel: Codable {
        var secretKey: String
        var location: EventLocation
    } 

    func scan() {
        guard NFCNDEFReaderSession.readingAvailable else {
            self.errorMessage = "This device doesn't support tag scanning."
            return
        }

        readerSession = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: true)
        readerSession?.alertMessage = "Get Closer to the Tag to Scan!"
        readerSession?.begin()

    }
    
    
    // MARK: delegate methods
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                DispatchQueue.main.async {
                    self.errorMessage = "Session invalidate with error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // for scanning NFC Data
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]){ }
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        DispatchQueue.main.async {
            self.processSuccess = false
        }
        
        // Restart polling in 500 milliseconds.
        func retry(message: String) {
            session.alertMessage = message
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
        }
        
        if tags.count > 1 {
            retry(message: "More than 1 tag is detected. Please remove all tags and try again.")
            return
        }
        
        guard let tag = tags.first else {
            retry(message: "Not able to get the first tag, please try again.")
            return
        }
        

        Task {
            var errorMessage: String? = nil

            do {
                try await session.connect(to: tag)
                let (status, _) = try await tag.queryNDEFStatus()
                
                switch status {
                case .notSupported:
                    let message = "Tag is not NDEF compliant."
                    session.alertMessage = message
                    errorMessage = message
                    
                case .readOnly:
                    let message = try await tag.readNDEF()
                    processNFCNDEFMessage(message)

                case .readWrite:
                    
                    let message = try await tag.readNDEF()
                    processNFCNDEFMessage(message)
                    
                @unknown default:
                    let message = "Unknown NDEF tag status."
                    session.alertMessage = message
                    errorMessage = message
                }
                
                session.invalidate()

            } catch(_) {
                let message = "Failed to read tags."
                session.alertMessage = message
                errorMessage = message
                session.invalidate()
                
            }
            
            DispatchQueue.main.async {[errorMessage] in
                self.errorMessage = errorMessage
                if errorMessage == nil {
                    self.processSuccess = true
                }
            }
        }
    }
    
    
    
    private func processNFCNDEFMessage(_ message: NFCNDEFMessage) {
        let records = message.records

        var containDataModel: Bool = false
        
        for record in records {
            if (record.typeNameFormat != .media) {
                continue
            }

            guard let type = String(data: record.type, encoding: .utf8), type == "application/json" else { continue }
            
            let data = record.payload
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                
                let result  = try decoder.decode(NFCDataModel.self, from: data)
                if result.secretKey != Constants.NFCConstants.secretKey {
                    continue
                }
                containDataModel = true
                location = result.location
                break
                
            } catch (let error) {
                print("decode fail with error: \(error)")
                continue
            }
        }
        
        if !containDataModel {
            DispatchQueue.main.async {
                self.errorMessage = "No matched record found on NFC Tags. "
            }
        }
    }
    
}


extension NFCTypeNameFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .nfcWellKnown: return "NFC Well Known type"
        case .media: return "Media type"
        case .absoluteURI: return "Absolute URI type"
        case .nfcExternal: return "NFC External type"
        case .unknown: return "Unknown type"
        case .unchanged: return "Unchanged type"
        case .empty: return "Empty payload"
        @unknown default: return "Invalid data"
        }
    }
}
