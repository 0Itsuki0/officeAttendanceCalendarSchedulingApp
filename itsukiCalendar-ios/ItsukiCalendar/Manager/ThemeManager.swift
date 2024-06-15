//
//  ThemeManager.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/16.
//

import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case pink
    case orange
    case red
    
    case purple
    case darkPurple
    case maroon

    case forestGreen
    case blue
    case navy
    
    var id: String {
        return self.rawValue
    }
    
    var iconName: String? {
        switch self {
        case .red:
            return nil
        default:
            return "\(self.rawValue)AppIcon"
        }
    }
    
    
    var color: Color {
        switch self {
        case .red:
            Color.red
        case .purple:
            Color.purple
        case .darkPurple:
            Color(red: 73/255, green: 46/255, blue: 135/255)
        case .maroon:
            Color(red: 108/255, green: 3/255, blue: 69/255)
        case .blue: 
            Color(red: 87/255, green: 85/255, blue: 254/255)
        case .navy:
            Color(red: 18/255, green: 20/255, blue: 129/255)
        case .pink:
            Color(red: 242/255, green: 123/255, blue: 189/255)
        case .forestGreen:
            Color(red: 0/255, green: 127/255, blue: 115/255)
        case .orange:
            Color.orange
        }
    }

}



class ThemeManager: ObservableObject {
    @Published var theme: Theme = .red
    @Published var errorMessage: String? = nil

    private let themeKey = "themeName"
    
    var color: Color {
        return theme.color
    }
    
    init() {

        let savedThemeName = UserDefaults.standard.value(forKey: themeKey) as? String ?? ""
        if let theme = Theme(rawValue: savedThemeName) {
            self.theme = theme
        } else {
            self.theme = .red
        }

    }
    
    func setTheme(_ theme: Theme) {
        self.theme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
        updateAppIcon()
    }
    
    
    func updateAppIcon() {
        DispatchQueue.main.async {
            UIApplication.shared.setAlternateIconName(self.theme.iconName, completionHandler: { error in
                if let error = error {
                    self.errorMessage = "Error Changing Icon: \(error.localizedDescription)!"
                }
            })
        }
    }

    
}
