//
//  PostNewEventRequest.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/11.
//

import Foundation

struct PostNewEventRequest: Requestable {
    
    var path: String = "/events"
    var method: RequestMethod = .post
    var header: [String : String]? = nil
    var body: [String : String]? = nil
    var queryParams: [String : String]? = nil
    var pathParams: [String : String]? = nil

    
    init(eventId: String, location: EventLocation, date: Date, userId: String) {
        self.body = [
            "id": eventId,
            "user_id": userId,
            "timestamp": date.naiveDateTime,
            "location": "\(location)"
        ]

    }
}
