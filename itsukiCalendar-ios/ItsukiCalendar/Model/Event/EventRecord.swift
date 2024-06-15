//
//  EventRecord.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/13.
//

import Foundation


struct EventRecord: Codable, Identifiable, Equatable {
    
    var id: String
    var location: EventLocation
    var status: EventStatus
    var timestamp: String
    var userId: String
    var userName: String

}


