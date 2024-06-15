//
//  PostNewEventResponse.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/11.
//

import Foundation

struct PostNewEventResponse: Codable {
    var error: Bool
    var event: EventRecord
}
