//
//  ContentView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/06.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var calendarModel: CalendarModel = CalendarModel()
    @StateObject var viewManager: ViewManager = ViewManager()
    @StateObject var themeManager: ThemeManager = ThemeManager()
    @StateObject var userManager: UserManager = UserManager()
    @StateObject var nfcManager: NFCManager = NFCManager()

    @State var showFullScreen = false

    var body: some View {
        let mainColor = themeManager.color        
        ZStack {

            if (viewManager.isInitializing) {
                LaunchContentView()
            } else {
                CalendarContentView()
            }
            
            
            if viewManager.isError {
                ErrorDialog(
                    color: mainColor,
                    error: viewManager.error,
                    isError: $viewManager.isError
                )
            }
            
            if viewManager.isLoading {
                LoadingView(colors: [mainColor, mainColor.opacity(0.3)])
            }
        }
        .environmentObject(calendarModel)
        .environmentObject(viewManager)
        .environmentObject(themeManager)
        .environmentObject(userManager)
        .environmentObject(nfcManager)
        
    }
}

#Preview {
    ContentView()

        
}
