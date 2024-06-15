//
//  GetPromotionCountRequest.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/06/02.
//

import Foundation

struct GetPromotionCountRequest: Requestable {
    
    var path: String = "/promotions/unused_count"
    var method: RequestMethod = .get
    var header: [String : String]? = nil
    var body: [String : String]? = nil
    var queryParams: [String : String]? = nil
    var pathParams: [String : String]? = nil
    
}
