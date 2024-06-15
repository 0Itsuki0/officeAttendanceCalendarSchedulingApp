//
//  EventModel.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/13.
//

import Foundation

struct OfficeState: Codable {
    var nagoya: [EventRecord]
    var nagaoka: [EventRecord]
    var tokyo: [EventRecord]
    
    init() {
        self.nagoya = []
        self.nagaoka = []
        self.tokyo = []
    }
    
    init(events: [EventRecord]) {
        self.nagoya = events.filter {$0.location == .nagoya}
        self.nagaoka = events.filter {$0.location == .nagaoka}
        self.tokyo = events.filter {$0.location == .tokyo}
    }
    
    func eventsForLocation(_ location: EventLocation) -> [EventRecord] {
        return switch location {
        case .nagoya:
            self.nagoya
        case .nagaoka:
            self.nagaoka
        case .tokyo:
            self.tokyo
        }
        
    }
    
    
    mutating func deleteEvent(_ eventId: String) {
        self.nagoya = self.nagoya.filter({$0.id != eventId})
        self.nagaoka = self.nagaoka.filter({$0.id != eventId})
        self.tokyo = self.tokyo.filter({$0.id != eventId})
    }
    
}
