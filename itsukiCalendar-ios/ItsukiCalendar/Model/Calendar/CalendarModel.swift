//
//  CalendarModel.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/06.
//

import SwiftUI

class CalendarModel: ObservableObject {
    @Published var selectedDayId: DayModel.ID? = nil {
        didSet(newValue) {
            if let newDayId = newValue, let dayModel = dayModelFromId(newDayId) {
                displayMonthId = monthIdForDay(dayModel)
                displayWeekId = weekIdForDay(dayModel)
            }
        }
    }
    var displayMonthId: MonthModel.ID?
    var displayWeekId: WeekModel.ID?

    
    @Published var dayList: [DayModel] = [] {
        didSet {
            monthList = makeMonthList()
            weekList = makeWeekList()
        }
    }
    
    var monthList: [MonthModel] = []
    var weekList: [WeekModel] = []

    
    init() {}
    
    func initializeModel(_ userId: String) async throws {
        let today = Date()
        let firstDayOfCurrentMonth = today.firstDayOfMonth
        var firstDayOfMonth = firstDayOfCurrentMonth.minusMonth(2)
        let firstDayOfLastMonth = firstDayOfCurrentMonth.plusMonth(2)
        let lastDayOfLastMonth = firstDayOfLastMonth.plusDate(firstDayOfLastMonth.daysInMonth)

        var dayList: [DayModel] = []
        let events = try await EventManager.getEventForUser(userId, from: firstDayOfMonth, to: lastDayOfLastMonth)

        for _ in 0..<5 {
            let daysInMonth = firstDayOfMonth.daysInMonth
            var date = firstDayOfMonth
            for _ in 0..<daysInMonth {
                let event = events.filter({date.isSameDate(Date.fromNaiveDateTime($0.timestamp))}).first

                dayList.append(DayModel(date, eventForCurrentUser: event))
                date = date.plusDate()
            }
            firstDayOfMonth = firstDayOfMonth.plusMonth()
        }
        
        DispatchQueue.main.async { [dayList] in
            self.dayList = dayList
            self.displayMonthId = self.idForCurrentMonth()
        }
    }
    

    func weekIdForDay(_ dayModel: DayModel) -> WeekModel.ID? {
        return weekList.first(where: {$0.dayList.contains(dayModel)})?.id
    }

    
    func weekIdForMonthRow(_ monthModel: MonthModel, row: Int) -> WeekModel.ID? {
        if row  > 0 {
            return monthModel.dayList[row*7]?.id
        }
        let startingSpace = monthModel.firstDayOfMonth.weekDay
        let firstDayOfWeek = monthModel.firstDayOfMonth.minusDate(startingSpace)
        let weekModel = weekList.first{$0.firstDayOfWeek == firstDayOfWeek}
        return weekModel?.id

    }

    
    func monthIdForDay(_ dayModel: DayModel) -> MonthModel.ID? {
        return monthList.first(where: {$0.dayList.contains(dayModel)})?.id
    }
    

    func idForPreviousMonth(_ currentMonthId: MonthModel.ID?) -> MonthModel.ID? {
        guard let currentMonthId = currentMonthId else {return nil}
        guard let index = monthList.firstIndex(where: {$0.id == currentMonthId}) else {return nil}
        if index == 0 {return nil}
        return monthList[index - 1].id
    }
    
    func idForNextMonth(_ currentMonthId: MonthModel.ID?) -> MonthModel.ID? {
        guard let currentMonthId = currentMonthId else {return nil}
        guard let index = monthList.firstIndex(where: {$0.id == currentMonthId}) else {return nil}
        if index == monthList.count - 1 {return nil}
        return monthList[index + 1].id
    }
    
    
    func idForCurrentMonth() -> MonthModel.ID? {
        let today = Date()
        let firstDayOfCurrentMonth = today.firstDayOfMonth
        let dayModel = dayList.first(where: ({$0.date == firstDayOfCurrentMonth}))
        return dayModel?.id
    }
    
    func idForToday() -> DayModel.ID? {
        let dayModel = dayList.first(where: ({$0.date.isToday}))
        return dayModel?.id
    }
    
    func monthModelFromId(_ id: MonthModel.ID?) -> MonthModel? {
        return monthList.first(where: {$0.id == id })
    }

    func dayModelFromId(_ id: DayModel.ID) -> DayModel? {
        return dayList.first(where: {$0.id == id})
    }
    
    
    func dayModelInWeek(_ weekId: WeekModel.ID) -> [DayModel] {
        guard let index = dayList.firstIndex(where: {$0.id == weekId}) else {return []}
        return Array(dayList[(index) ..< (index + 7)])
    }
    
    
    // MARK: - Events related
    
    func deleteCurrentUserEvent() async throws {
        guard let dayId = selectedDayId else {return}
        let dayModel = dayModelFromId(dayId)
        guard let dayModel = dayModel else {return}
        
        guard let index = dayList.firstIndex(where: {$0.id == dayId}) else {return}
        try await dayModel.deleteCurrentUserEvent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [dayModel] in
            withAnimation {
                self.dayList[index] = dayModel
            }
        }
    }
    
    func addEventForUser(_ userId: String, location: EventLocation) async throws {
        guard let dayId = selectedDayId else {return}
        let dayModel = dayModelFromId(dayId)
        guard let dayModel = dayModel else {return}
        
        guard let index = dayList.firstIndex(where: {$0.id == dayId}) else {return}
        try await dayModel.addEventForUser(userId, location: location)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [dayModel] in
            withAnimation {
                self.dayList[index] = dayModel
            }
        }
    }
    
    func updateEventStatusForUser(_ userId: String, at location: EventLocation) async throws {
        let dayModel = dayList.first(where: ({$0.date.isToday}))
        guard let dayModel = dayModel else {return}
        guard let index = dayList.firstIndex(where: {$0.id == dayModel.id}) else {return}

        var error: Error?
        do {
            try await dayModel.updateEventStatusForUser(userId, at: location)
        } catch (let e) {
            error = e
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [dayModel] in
            withAnimation {
                self.dayList[index] = dayModel
                self.selectedDayId = dayModel.id

            }
        }
        if let error = error {
            throw error
        }
        
    }

    func fetchOfficeState(_ dayId: DayModel.ID, currentUserId: String) async throws {

        let dayModel = dayModelFromId(dayId)
        guard let dayModel = dayModel else {return}

        guard let index = dayList.firstIndex(where: {$0.id == dayId}) else {return}
        try await dayModel.fetchOfficeState(currentUserId: currentUserId)
        
        DispatchQueue.main.async { [dayModel] in
            self.dayList[index] = dayModel
        }
    }
    
    
    // MARK: - Loading related
    
    func loadMoreIfNeeded(dayId: DayModel.ID, for userId: String) throws  {
        Task {
            guard let currentDayIndex = dayList.firstIndex(where: {$0.id == dayId}) else {return}
        
            if currentDayIndex >= dayList.count - 1 {
                try await addMonthAfter(1, for: userId)
            } else if currentDayIndex <=  0 {
                try await addMonthBefore(1, for: userId)
            }
        }

    }
    
    func loadMoreIfNeeded(monthId: MonthModel.ID, for userId: String) throws  {
        Task {
            if monthId == monthList.last?.id {
                try await addMonthAfter(2, for: userId)
            } else if monthId == monthList.first?.id {
                try await addMonthBefore(2, for: userId)

            }
        }
    }
    
    func loadMoreIfNeeded(weekId: WeekModel.ID, for userId: String) throws {
        
        Task {
            guard let currentWeekIndex = weekList.firstIndex(where: {$0.id == weekId}) else {return}
        
            if currentWeekIndex >= weekList.count - 1 {
                try await addMonthAfter(1, for: userId)
            } else if currentWeekIndex <=  0 {
                try await addMonthBefore(1, for: userId)
            }
        }
    }
    
    
    // MARK: - Private functions
    
    private func makeWeekList() -> [WeekModel] {
        if dayList.isEmpty {
            return []
        }
        var index = dayList.firstIndex(where: {$0.date.weekDay == 0}) ?? 0
        var weekList: [WeekModel] = []
        while index < dayList.count - 8 {
            let weekModel = WeekModel(Array(dayList[index ..< index + 7]))
            weekList.append(weekModel)
            index = index + 7
        }
        return weekList
    }
    
    private func makeMonthList() -> [MonthModel] {
        if dayList.isEmpty {
            return []
        }
        var firstDate = dayList[0].date

        var index = 0
        var endIndex = firstDate.daysInMonth
        var monthList: [MonthModel] = []
        while endIndex <= dayList.count {
            let monthModel = MonthModel(Array(dayList[index ..< endIndex]))
            monthList.append(monthModel)
            
            firstDate = firstDate.plusMonth()
            index = endIndex
            endIndex = endIndex + firstDate.daysInMonth
        }
        
        return monthList
    }
    
    private func addMonthAfter(_ count: Int, for userId: String) async throws {

        var firstDayOfFirstMonth = dayList.last!.date.firstDayOfMonth
        firstDayOfFirstMonth = firstDayOfFirstMonth.plusMonth()
        
        let firstDayOfLastMonth = firstDayOfFirstMonth.plusMonth(count - 1)
        let lastDayOfLastMonth = firstDayOfLastMonth.plusDate(firstDayOfLastMonth.daysInMonth)
        
        let events = try await EventManager.getEventForUser(userId, from: firstDayOfFirstMonth, to: lastDayOfLastMonth)
        var newDayList: [DayModel] = []
        
        for _ in 0..<count {
            let daysInMonth = firstDayOfFirstMonth.daysInMonth
            var date = firstDayOfFirstMonth

            for _ in 0..<daysInMonth {
                let event = events.filter({date.isSameDate(Date.fromNaiveDateTime($0.timestamp))}).first
                newDayList.append(DayModel(date, eventForCurrentUser: event))
                date = date.plusDate()
            }
            
            firstDayOfFirstMonth = firstDayOfFirstMonth.plusMonth()

        }
        
        DispatchQueue.main.async { [newDayList] in
            self.dayList.append(contentsOf: newDayList)
        }
    }
    
    
    
    private func addMonthBefore(_ count: Int, for userId: String) async throws {
        var firstDayOfFirstMonth = dayList.first!.date.firstDayOfMonth
        firstDayOfFirstMonth = firstDayOfFirstMonth.minusMonth(count)
        
        let firstDayOfLastMonth = firstDayOfFirstMonth.plusMonth(count - 1)
        let lastDayOfLastMonth = firstDayOfLastMonth.plusDate(firstDayOfLastMonth.daysInMonth)

        let events = try await EventManager.getEventForUser(userId, from: firstDayOfFirstMonth, to: lastDayOfLastMonth)
        var newDayList: [DayModel] = []

        for _ in 0..<count {
            let daysInMonth = firstDayOfFirstMonth.daysInMonth
            var date = firstDayOfFirstMonth

            for _ in 0..<daysInMonth  {
                let event = events.filter({date.isSameDate(Date.fromNaiveDateTime($0.timestamp))}).first
                newDayList.append(DayModel(date, eventForCurrentUser: event))
                date = date.plusDate()
            }
            
            firstDayOfFirstMonth = firstDayOfFirstMonth.plusMonth()
        }
        
        DispatchQueue.main.async { [newDayList] in
            self.dayList.insert(contentsOf: newDayList, at: 0)
        }
    }
}
