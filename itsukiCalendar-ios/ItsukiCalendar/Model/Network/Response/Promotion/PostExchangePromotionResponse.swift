//
//  GetPromotionSingleResponse.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/06/02.
//

import Foundation

struct PostExchangePromotionResponse: Codable {
    var error: Bool
    var promotion: Promotion
}
