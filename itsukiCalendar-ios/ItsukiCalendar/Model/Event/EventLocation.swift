//
//  Location.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/13.
//

import Foundation


enum EventLocation: String, Codable, CaseIterable, Identifiable {
    case nagoya
    case nagaoka
    case tokyo
    
}

extension EventLocation {
    var id: String {
        return "\(self)"
    }

    var title: String {
        return switch self {
        case .nagoya:
            "NAGOYA"
        case .nagaoka:
            "NAGAOKA"
        case .tokyo:
            "TOKYO"
        }
    }
}
