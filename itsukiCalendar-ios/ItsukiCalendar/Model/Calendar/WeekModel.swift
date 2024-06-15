//
//  WeekModel.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/12.
//

import Foundation

struct WeekModel: Identifiable, Equatable {
    let id: UUID
    
    var firstDayOfWeek: Date
    var dayList: [DayModel]
    
    init(_ dayList: [DayModel]) {
        self.dayList = dayList
        self.id = dayList[0].id
        self.firstDayOfWeek = dayList[0].date

    }
    
    static func == (lhs: WeekModel, rhs: WeekModel) -> Bool{
        return lhs.id == rhs.id
    }
    
}

