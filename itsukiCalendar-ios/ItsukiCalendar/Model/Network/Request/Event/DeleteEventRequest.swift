//
//  DeleteEventRequest.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/11.
//

import Foundation

struct DeleteEventRequest: Requestable {
    
    var path: String = "/events/:event_id"
    var method: RequestMethod = .delete
    var header: [String : String]? = nil
    var body: [String : String]? = nil
    var queryParams: [String : String]? = nil
    var pathParams: [String : String]? = nil
    
    
    init(eventId: String) {
        self.pathParams = [":event_id": eventId]
    }

    
}
