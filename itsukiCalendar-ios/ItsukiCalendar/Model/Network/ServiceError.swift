//
//  ServiceError.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/03.
//

import Foundation

enum ServiceError: Error {
    case urlCreation
    case timeout
    case parsing
    case badRequest(reason: String)
    
    var message: String {
        switch self {
        case .timeout:
            "Oops! Please Check your Network!"
        case .badRequest(let reason):
            "Oops! Failed due to \(reason)"
        default:
            "Oops! Please Try Again!"
        }
    }
}


struct ServiceErrorResponse: Codable {
    var error: Bool
    var message: String
}
