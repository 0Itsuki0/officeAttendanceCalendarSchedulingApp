//
//  PagedDayViewTabBar.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/12.
//

import SwiftUI

struct DayViewTabBar: View {
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var viewManager: ViewManager

    var mainColor: Color

    @State private var weekId: WeekModel.ID?
    
    var body: some View {
        let weekList = calendarModel.weekList
        let selectedIndex = calendarModel.dayModelFromId(calendarModel.selectedDayId ?? UUID())?.date.weekDay

        
        ScrollView(.horizontal) {
            LazyHStack(
                spacing: 0
            ) {
                ForEach(weekList) { weekModel in

                    HStackWithPadding{
                        ForEach(weekModel.dayList) { dayModel in
                            let isSelected = dayModel.id == calendarModel.selectedDayId

                            DayView(dayModel: dayModel, showDecoration: false, isSelected: isSelected, mainColor: mainColor)
                            
                        }
                    }
                    .frame(width: UIScreen.main.bounds.size.width)
                }
            }
            .scrollTargetLayout()
           
        }
        .scrollPosition(id: $weekId)
        .onAppear{
            if let dayId = calendarModel.selectedDayId,
                let dayModel = calendarModel.dayModelFromId(dayId),
               let weekId = calendarModel.weekIdForDay(dayModel)  {
                self.weekId = weekId
            }
        }
        .onChange(of: weekId) {
            guard let weekId = weekId else { return }
            
            do {
                try calendarModel.loadMoreIfNeeded(weekId: weekId, for: userManager.userId)
            } catch(let error) {
                viewManager.showError(error: error)
            }
            
            let daysInWeek = calendarModel.dayModelInWeek(weekId)
            
            // selected date within days in week
            if !daysInWeek.filter({$0.id == calendarModel.selectedDayId}).isEmpty {
                return
            }
            
            if let selectedIndex = selectedIndex {
                withAnimation {
                    calendarModel.selectedDayId = daysInWeek[selectedIndex].id
                }
            }
        }
        .onChange(of: calendarModel.displayWeekId) {
            self.weekId = calendarModel.displayWeekId
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .padding(.all, 0)
        .frame(height: 50, alignment: .center)
        

    }
        
}


#Preview {
    let calendarModel: CalendarModel = CalendarModel()
    let viewManager: ViewManager = ViewManager()
    let themeManager: ThemeManager = ThemeManager()
    let userManager: UserManager = UserManager()

    return DayViewTabBar(mainColor: .red)
        .environmentObject(calendarModel)
        .environmentObject(viewManager)
        .environmentObject(themeManager)
        .environmentObject(userManager)
        .task {
            try? await calendarModel.initializeModel(userManager.userId)
            let dayModel = calendarModel.dayList[10]
            calendarModel.selectedDayId = dayModel.id
        }

}
