//
//  DayView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/06.
//

import SwiftUI

struct DayView: View {
    @EnvironmentObject var calendarModel: CalendarModel

    var dayModel: DayModel?
    var showDecoration: Bool
    var isSelected: Bool
    var mainColor: Color

    var body: some View {
        let height: CGFloat = showDecoration ? 55 : 40
        VStack(
            alignment: .center,
            spacing: 8
        ) {
            if let dayModel = dayModel {
                let isToday =  dayModel.date.isToday
                let isWeekend = dayModel.date.isWeekend
                
                let hasEvent = (dayModel.eventForCurrentUser != nil)

                let foregroundColor =  isSelected ? Color.white : isToday ? mainColor : isWeekend ? Color(UIColor.systemGray3) : Color.black
                let backgroundColor = (isToday && isSelected) ? mainColor : isSelected ? Color.black : Color.clear

                
                Button(action: {
                    print("day selected")
                    withAnimation {
                        calendarModel.selectedDayId = dayModel.id
                    }
                }, label: {
                    Text("\(dayModel.date.day)")
                })
                .padding(8)
                .font(.system(size: 18))
                .fontWeight(
                    isToday ? Font.Weight.bold : Font.Weight.regular
                )
                .foregroundStyle(foregroundColor)
                .background(Circle()
                    .fill(backgroundColor)
                    .frame(width: 35, height: 35, alignment: .center)
                )
                if (hasEvent && showDecoration) {
                    Circle()
                        .fill(Color(UIColor.gray))
                        .frame(width: 8, height: 8)
                }
            }
            
                
        }
        .frame(width: 40, height: height, alignment: .top)
        .padding(.vertical, 5)
    }
}


#Preview {
    DayView(dayModel: DayModel(Date()), showDecoration: true, isSelected: true, mainColor: .red)
}

