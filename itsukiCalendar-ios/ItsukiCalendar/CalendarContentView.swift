//
//  CalendarContentView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/14.
//

import SwiftUI


struct CalendarContentView: View {
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager

    @Namespace var animation
        
    var body: some View {
        
        ZStack {

            if let fullScreenView = viewManager.fullScreenView {
                Group {
                    switch fullScreenView {
                    case .addEvent:
                        AddEventView()
                    case .setting:
                        SettingView()
                    case .promotionExchange:
                        PromotionExchangeView()
                    }
                }
                .background(Color.white)
                .transition(.move(edge: .bottom))
            } else {
                if (calendarModel.selectedDayId == nil) {
                    MonthlyScrollView(animation: animation)
                } else {
                    DailyEventView(animation: animation)
                }

            }
            
        }

    }
    
}
