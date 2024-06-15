//
//  User.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/13.
//

import Foundation

struct User: Codable {
    var id: String
    var username: String
    var password: String?
    var pointsRemained: Int
    var pointsUsed: Int
    var totalAttendance: Int
}

