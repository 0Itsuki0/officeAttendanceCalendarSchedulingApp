//
//  EventManager.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/18.
//

import Foundation

class EventManager {
    
    static func getEventsForDate(_ date: Date) async throws  -> [EventRecord] {
        let request = GetEventsRequest(startDate: date, endDate: date.plusDate())
        let response = try await request.sendRequest(responseType: GetEventsResponse.self)
        let events = response.events.filter({!date.plusDate().isSameDate(Date.fromNaiveDateTime($0.timestamp))})
        return events
    }
    
    static func getEventForUser(_ userId: String, from start: Date, to end: Date) async throws -> [EventRecord]  {
        let request = GetEventsRequest(userId: userId, startDate: start, endDate: end.plusDate())
        let response = try await request.sendRequest(responseType: GetEventsResponse.self)
        let events = response.events.filter({!end.plusDate().isSameDate(Date.fromNaiveDateTime($0.timestamp))})
        return events
    }
    
    static func deleteEvent(_ eventId: String) async throws {
        let request = DeleteEventRequest(eventId: eventId)
        let _ = try await request.sendRequest(responseType: DeleteEventResponse.self)
        return
    }

    static func addNewEvent(userId: String, date: Date, location: EventLocation) async throws  -> EventRecord{
        let eventId = UUID().uuidString
        let request = PostNewEventRequest(eventId: eventId, location: location, date: date, userId: userId)
        let response = try await request.sendRequest(responseType: PostNewEventResponse.self)
        return response.event
    }
    
    static func updateEventStatus(eventId: String) async throws {
        let request = PutEventStatusRequest(eventId: eventId, status: .went)
        let _ = try await request.sendRequest(responseType: PutEventStatusResponse.self)
        return
    }
    
}
