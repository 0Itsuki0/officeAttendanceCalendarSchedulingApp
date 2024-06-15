//
//  DayModel.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/06.
//

import Foundation


class DayModel: Identifiable, Equatable  {
    let id: UUID = UUID()
    
    var date: Date
    
    var eventForCurrentUser: EventRecord? = nil
    var events: [EventRecord] = []
        
    init(_ date: Date, eventForCurrentUser: EventRecord? = nil) {
        self.date = date
        self.eventForCurrentUser = eventForCurrentUser
    }
    
    func fetchOfficeState(currentUserId: String) async throws  {
        let events = try await EventManager.getEventsForDate(self.date)
        self.eventForCurrentUser = events.filter({$0.userId == currentUserId}).first
        self.events = events.filter({$0.status != .absence})
    }
    
    
    func deleteCurrentUserEvent() async throws {
        guard let event = eventForCurrentUser else {return}
        try await EventManager.deleteEvent(event.id)
        self.eventForCurrentUser = nil
        let _ = events.removeAll(where: {$0.id == event.id})
    }
    
    func addEventForUser(_ userId: String, location: EventLocation) async throws {
        let newEvent = try await EventManager.addNewEvent(userId: userId, date: self.date, location: location)
        self.eventForCurrentUser = newEvent
        self.events.append(newEvent)
    }
    
    func updateEventStatusForUser(_ userId: String, at location: EventLocation) async throws{
        if eventForCurrentUser == nil {
            try await addEventForUser(userId, location: location)
        } else if eventForCurrentUser?.location != location {
            try await deleteCurrentUserEvent()
            try await addEventForUser(userId, location: location)
        }
        
        if let eventId = eventForCurrentUser?.id {
            try await EventManager.updateEventStatus(eventId: eventId)
            try await fetchOfficeState(currentUserId: userId)
        }
    }
    
    
    static func == (lhs: DayModel, rhs: DayModel) -> Bool{
        return lhs.id == rhs.id
    }
    
}

