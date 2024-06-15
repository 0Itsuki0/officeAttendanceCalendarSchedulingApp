//
//  CurrentUserEventView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/29.
//

import SwiftUI

struct CurrentUserEventView: View {
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var themeManager: ThemeManager

    var event: EventRecord
    
    var body: some View {
        let color = themeManager.color
        
        HStack(
            alignment: .center,
            spacing: 10
        ) {
            Image(systemName: "location.fill")
            Text(event.location.title)
                .lineLimit(1)
            Spacer()
            
            if event.status == . went {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(themeManager.color)
                    .font(.system(size: 24, weight: .regular))

            } else {
                LongPressToActionButton(actionFunction: {
                    do {
                        try await calendarModel.deleteCurrentUserEvent()
                    } catch (let error) {
                        viewManager.showError()
                        throw error
                    }
                    
                }, startImageName: "trash", color: themeManager.color, enabled: true)
            }

        }
//        .padding(.horizontal, 10)
        .font(.system(size: 18))
        .frame(maxWidth: .infinity)
        .frame(height: 36, alignment: .center)
        .foregroundStyle(color)
        .modifier(RoundedBorder(verticalPadding: 16, borderColor: .clear, backgroundColor: color.opacity(0.3)))
    }
}


#Preview {
    let viewManager = ViewManager()
    let calendar = CalendarModel()
    let themeManager = ThemeManager()

    let event = EventRecord(id: UUID().uuidString, location: .nagoya, status: .going, timestamp: Date().naiveDateTime, userId: "test@example.com", userName: "test")
    @State var dayModel: DayModel?
    
    return CurrentUserEventView(event: event)
        .environmentObject(viewManager)
        .environmentObject(calendar)
        .environmentObject(themeManager)

}
