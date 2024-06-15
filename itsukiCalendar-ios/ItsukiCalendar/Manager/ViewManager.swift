//
//  ViewManager.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/15.
//

import SwiftUI

class ViewManager: ObservableObject {
    
    @Published var fullScreenView: FullScreenView? = nil

    @Published var isInitializing: Bool = true
    @Published var loginView: Bool = false

    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    var error: ErrorDialogParameter? = nil
    
    @Published var viewEventLocationDropdown: Bool = false
    @Published var addEventLocationDropdown: Bool = false
    @Published var selectedLocationIndex: Int = 0

    
    enum FullScreenView: Identifiable {
        case addEvent
        case setting
        case promotionExchange
        
        var id: String {
            return "\(self)"
        }
    }
    
    func showFullScreenView(_ view: FullScreenView) {
        DispatchQueue.main.async {
            withAnimation(.linear(duration: 0.25)) {
                self.fullScreenView = view
            }
        }
    }
    
    func hideFullScreenView(animated: Bool = true) {
        if animated {
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.25)) {
                    self.fullScreenView = nil
                }
            }
        } else {
            DispatchQueue.main.async {
                self.fullScreenView = nil
            }
        }
        
    }
    

    func initializeFinish() {
        DispatchQueue.main.async {
            withAnimation {
                self.isInitializing = false
            }
        }
    }
    
    func showLogin() {
        DispatchQueue.main.async {
            withAnimation {
                self.loginView = true
            }
        }
    }
    
    func hideLogin() {
        DispatchQueue.main.async {
            self.loginView = false
        }
    }
    
    
    func showLoader() {
        DispatchQueue.main.async {
            withAnimation {
                self.isLoading = true
            }
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func showError(_ message: String = "") {
        print("error: \(message)")

        self.error = ErrorDialogParameter(errorMessage: message, performActionAfterClosed: {})
        DispatchQueue.main.async {
            self.isLoading = false
            withAnimation {
                self.isError = true
            }
        }
    }
    
    func showError(error: Error, performActionAfterClosed: @escaping () -> Void = {}) {
        print("error: \(error.localizedDescription)")
        
        var message = ""
        if let error = error as? ServiceError {
            message = error.message
        }
        self.error = ErrorDialogParameter(errorMessage: message, performActionAfterClosed: performActionAfterClosed)

        DispatchQueue.main.async {
            self.isLoading = false
            withAnimation {
                self.isError = true
            }
        }
    }
    
    func hideError() {
        DispatchQueue.main.async {
            self.isError = false
            self.error = nil
        }
    }
    
    
    func showViewEventLocationDropDown() {
        DispatchQueue.main.async {
            withAnimation {
                self.viewEventLocationDropdown = true
            }
        }
    }
    
    func hideViewEventLocationDropDown() {
        DispatchQueue.main.async {
            withAnimation {
                self.viewEventLocationDropdown = false
            }
        }
    }
    
    func showAddEventLocationDropDown() {
        DispatchQueue.main.async {
            withAnimation {
                self.addEventLocationDropdown = true
            }
        }
    }
    
    func hideAddEventLocationDropDown() {
        DispatchQueue.main.async {
            withAnimation {
                self.addEventLocationDropdown = false
            }
        }
    }
}
