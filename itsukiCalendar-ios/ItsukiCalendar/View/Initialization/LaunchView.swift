//
//  LaunchView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/28.
//

import SwiftUI


struct InitialView: View {
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private let phases: [CGFloat] = [-3, -2, -1, 0, 1, 2, 3, 2, 1, 0, -1, -2]
    
    var body: some View {
        let color = themeManager.color
        
        GeometryReader {geometry in
            let offset = (geometry.size.width - 100) / CGFloat(phases.count/2)
            PhaseAnimator(phases, content: {phase in
                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundStyle(color)
                    .rotationEffect(Angle(degrees: Int(phase)%2 == 0 ? -40 : 20))
                    .offset(x: phase * offset)
                }, animation: { phase in
                        .bouncy(duration: 0.5)
                })
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onAppear {
                if userManager.shouldPromptUserNameEntry() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        viewManager.showLogin()
                    }
                } else {
                    initializeModel()
                }
            }

        }
    }
    
    private func initializeModel() {
        Task {
            do {
                try await calendarModel.initializeModel(userManager.userId)
                viewManager.initializeFinish()
            } catch(let error) {
                viewManager.showError(error: error, performActionAfterClosed: {initializeModel()})
            }
        }

    }
}


#Preview {
    @StateObject var calendarModel = CalendarModel()
    @StateObject var viewManager = ViewManager()
    @StateObject var themeManager = ThemeManager()
    @StateObject var userManager = UserManager()

    return InitialView()
        .environmentObject(calendarModel)
        .environmentObject(viewManager)
        .environmentObject(userManager)
        .environmentObject(themeManager)

}
