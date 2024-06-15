//
//  PutEventStatusRequest.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/03.
//

import Foundation

struct PutEventStatusRequest: Requestable {
    
    var path: String = "/events/:event_id"
    var method: RequestMethod = .put
    var header: [String : String]? = nil
    var body: [String : String]?
    var queryParams: [String : String]? = nil
    var pathParams: [String : String]?
    
    
    init(eventId: String, status: EventStatus) {
        self.pathParams = [":event_id": eventId]
        self.body = ["status": "\(status)"]
    }
        
}
