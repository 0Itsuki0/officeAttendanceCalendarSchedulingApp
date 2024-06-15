//
//  GetPromotionCountResponse.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/06/02.
//

import Foundation

struct GetPromotionCountResponse: Codable {
    var error: Bool
    var promotionCount: PromotionCount
}
