//
//  GetEventRequest.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/03.
//

import Foundation

struct GetEventsRequest: Requestable {    
    
    var path: String = "/events"
    var method: RequestMethod = .get
    var header: [String : String]? = nil
    var body: [String : String]? = nil
    var queryParams: [String : String]? = nil
    var pathParams: [String : String]? = nil
    
    
    init(userId: String, startDate: Date, endDate: Date) {
        self.queryParams = [
            "user_id": userId,
            "start_time": "\(startDate.naiveDateTime)",
            "end_time": "\(endDate.naiveDateTime)",
        ]
    }
    
    init(startDate: Date, endDate: Date) {
        self.queryParams = [
            "start_time": "\(startDate.naiveDateTime)",
            "end_time": "\(endDate.naiveDateTime)",
        ]
    }
    
}
