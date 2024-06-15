//
//  GetPromotionSingleRequest.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/06/02.
//

import Foundation

import Foundation

struct PostExchangePromotionRequest: Requestable {
    
    var path: String = "/promotions/exchange"
    var method: RequestMethod = .post
    var header: [String : String]? = nil
    var body: [String : String]? = nil
    var queryParams: [String : String]? = nil
    var pathParams: [String : String]? = nil
    
    
    init(type: PromotionType, id: String) {
        self.body = [
            "type": "\(type.rawValue)",
            "user_id": id
        ]
    }
    
}
