//
//  PromotionType.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/04.
//

import Foundation


enum PromotionType: String, Codable, CaseIterable, Identifiable {
    case amazon = "amazon"
    case apple = "apple"
    case googlePlay = "google_play"
    case nintendo = "nintendo"
    
    var id: String {
        return "\(self)"
    }
    
    var title: String {
        switch self {
        case .amazon:
            "Amazon Gift Card"
        case .apple:
            "Apple Gift Card"
        case .googlePlay:
            "GooglePlay Gift Card"
        case .nintendo:
            "Nintendo Gift Card"
        }
    }
}
