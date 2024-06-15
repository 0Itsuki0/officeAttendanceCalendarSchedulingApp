//
//  MonthView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/06.
//

import SwiftUI

struct MonthView: View {
    var monthModel: MonthModel
    var isDateSelection: Bool = false
    var selectedDateId: DayModel.ID?
    var mainColor: Color

    @State private var leadingPadding: CGFloat?

    
    var body: some View {
        let coordinateSpaceName: String = "monthViewVStack"

        let firstDayOfMonth = monthModel.firstDayOfMonth
        let startingSpaces = firstDayOfMonth.weekDay

        let isCurrentMonth = firstDayOfMonth.isCurrentMonth

        VStack(
            alignment: .center,
            spacing: 10
        ) {
            if let leadingPadding = leadingPadding {
                if !isDateSelection {
                    // month label
                    Text("\(firstDayOfMonth.localizedMonthShort)")
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20))
                        .fontWeight(
                            Font.Weight.bold
                        )
                        .foregroundStyle(
                            isCurrentMonth ? mainColor : Color.black
                        )
                        .padding(.leading, leadingPadding + 5)
                        .foregroundStyle(mainColor)
                }
            }

            // days
            ForEach(0..<monthModel.numberOfRows(), id: \.self) { row in
                
                
                // row
                HStackWithPadding {
                    ForEach(0..<7) { column in
                        let dayIndex = column + (row * 7)
                        let dayModel = monthModel.dayList[dayIndex]
                        
                        let isSelected: Bool = isDateSelection ? (dayModel?.id == selectedDateId) : dayModel?.date.isToday ?? false
                       
                        DayView(dayModel: dayModel, showDecoration: true, isSelected: isSelected, mainColor: mainColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .overlay(GeometryReader{ geometry -> Color in
                                if (dayIndex == startingSpaces) {
                                    DispatchQueue.main.async {
                                        leadingPadding  = geometry.frame(in: .named(coordinateSpaceName)).minX
                                    }
                                }
                                
                                return Color.clear
                            })
                            
                    }
                }

            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .coordinateSpace(name: coordinateSpaceName)

    }
    
}









#Preview {
    let today = Date()
    let firstDayOfCurrentMonth = today.firstDayOfMonth
    let firstDayOfMonth = firstDayOfCurrentMonth

    var dayList: [DayModel] = []

    let daysInMonth = firstDayOfMonth.daysInMonth
    var date = firstDayOfMonth
    for _ in 0..<daysInMonth {
        dayList.append(DayModel(date))
        date = date.plusDate()
    }


    return MonthView(monthModel: MonthModel(dayList), mainColor: .red)
            .background(Color.blue)

}
