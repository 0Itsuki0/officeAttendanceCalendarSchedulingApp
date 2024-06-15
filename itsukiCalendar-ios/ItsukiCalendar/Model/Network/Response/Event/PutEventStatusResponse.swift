//
//  PutEventResponse.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/03.
//

import Foundation

struct PutEventStatusResponse: Codable {
    var error: Bool
    var event: EventRecord
}
