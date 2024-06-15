//
//  Promotion.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/06/02.
//

import Foundation

struct Promotion: Codable {
    var id: String
    var promotionType: PromotionType
    var promotionCode: String
    var promotionValue: Int
    var pointsRequired: Int
    var exchangedDate: String?
    var exchangedBy: String?
}
