//
//  MonthModel.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/06.
//

import Foundation


class MonthModel: Identifiable, Equatable {
    let id: UUID
    
    var firstDayOfMonth: Date
    var dayList: Array<DayModel?>

    // dayList: actual days
    init(_ dayList: [DayModel]) {
        
        // starting empty spaces
        let startingSpaces = dayList[0].date.weekDay
        var dayModelList: [DayModel?] = Array(repeating: nil, count: startingSpaces)

        dayModelList.append(contentsOf: dayList)
        
        // trailing empty spaces
        let monthRowCount = Int(ceil((Double(dayList.count + startingSpaces)/7)))
        let trailingSpaces: [DayModel?] = Array(repeating: nil, count: monthRowCount * 7 - dayList.count - startingSpaces)
        dayModelList.append(contentsOf: trailingSpaces)
        
        self.firstDayOfMonth = dayList[0].date
        self.dayList = dayModelList
        self.id = dayList[0].id
    }
    
    
    func numberOfRows() -> Int {
        let days = firstDayOfMonth.daysInMonth
        let startingSpaces = firstDayOfMonth.weekDay
        let monthRowCount = Int(ceil((Double(days + startingSpaces)/7)))
        return monthRowCount
    }
    
    func modelForFirstDay() -> DayModel? {
        return dayList.first(where: {$0 != nil}) ?? nil
    }
    

    static func == (lhs: MonthModel, rhs: MonthModel) -> Bool{
        return lhs.id == rhs.id
    }
}

