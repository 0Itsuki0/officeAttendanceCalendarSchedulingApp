//
//  EventView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/13.
//


import SwiftUI

struct PagedEventView: View {
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
    
        ScrollView(.horizontal) {
            LazyHStack(
                spacing: 0
            ) {
                
                ForEach(calendarModel.dayList) { dayModel in
                    ScrollView(.vertical) {
                        VStack(spacing: 20){
                            // event for current user?
                            if let eventForCurrentUser = dayModel.eventForCurrentUser {
                                CurrentUserEventView(event: eventForCurrentUser)
                            }
                            // office State
                            OfficeStateView(events: dayModel.events)
//                            OfficeStateView(dayModel: dayModel)
//                            OfficeStateView(officeState: dayModel.officeState)

                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .scrollTargetLayout()
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .frame(width: UIScreen.main.bounds.size.width)
                    .background(Color.white)
                    
                }
            }
            .scrollTargetLayout()
            .background(Color.yellow)
           
        }
        .scrollPosition(id: $calendarModel.selectedDayId)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .padding(.vertical, 10)
        .frame( maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
        
}


#Preview {
    let calendarModel: CalendarModel = CalendarModel()
    let viewManager: ViewManager = ViewManager()
    let themeManager: ThemeManager = ThemeManager()
    let userManager: UserManager = UserManager()


    return PagedEventView()
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

