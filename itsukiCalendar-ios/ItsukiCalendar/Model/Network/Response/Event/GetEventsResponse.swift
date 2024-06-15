//
//  GetEventsResponse.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/03.
//

import Foundation

struct GetEventsResponse: Codable {
    var error: Bool
    var events: [EventRecord]
}
