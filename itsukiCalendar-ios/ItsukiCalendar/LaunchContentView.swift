//
//  LaunchContentView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/28.
//

import SwiftUI


struct LaunchContentView: View {
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager

    @Namespace var animation
        
    var body: some View {
        ZStack {
            if (viewManager.loginView) {
                LoginView()
            } else {
                InitialView()
            }

        }
    }
}
