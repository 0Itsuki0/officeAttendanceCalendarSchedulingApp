//
//  PromotionManager.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/04.
//

import Foundation

class PromotionManager {
    
    public static func exchangePromotion(_ promotionType: PromotionType, for userId: String) async throws -> String {
        let request = PostExchangePromotionRequest(type: promotionType, id: userId)
        let response = try await request.sendRequest(responseType: PostExchangePromotionResponse.self)
        return response.promotion.promotionCode
    }
    
    public static func getPromotionCount() async throws -> PromotionCount {
        let request = GetPromotionCountRequest()
        let response = try await request.sendRequest(responseType: GetPromotionCountResponse.self)
        return response.promotionCount
    }
}
