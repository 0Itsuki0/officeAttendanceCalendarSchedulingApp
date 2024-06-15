//
//  DateSelectionView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/21.
//

import SwiftUI

struct DateSelectionView: View {
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager

    var viewWidth: CGFloat

    @State private var monthId: MonthModel.ID?
    
    var body: some View {
        let color = themeManager.color
        let displayedMonthModel = calendarModel.monthModelFromId(monthId ?? calendarModel.idForCurrentMonth())

        // date selection
        VStack(spacing: 0) {
            
            // header
            VStack (
                alignment: .center,
                spacing: 10
            ) {
                HStack {
                    //  label
                    HStack(
                        alignment: .center,
                        spacing: 10
                    ) {
                        Text(Image(systemName: "star.fill"))
                            .font(.system(size: 15, weight: .bold))
                        Text(displayedMonthModel?.firstDayOfMonth.localizedYearMonth ?? "")
                           .font(.system(size: 20))
                    }

                    Spacer()
                        .frame(maxWidth: .infinity)
                    
                    HStack(
                        alignment: .center,
                        spacing: 20
                    ) {
                        Button(action: {
                            withAnimation {
                                monthId = calendarModel.idForPreviousMonth(monthId)
                            }
                        }, label: {
                            Image(systemName: "chevron.left")

                        })
                        Button(action: {
                            withAnimation {
                                monthId = calendarModel.idForNextMonth(monthId)
                            }
                        }, label: {
                            Image(systemName: "chevron.right")
                        })
                    }
                    .font(.system(size: 15, weight: .bold))

                }
                .padding(.horizontal, 20)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .center)

                
                // weekday label
                WeekdayHeaderView(color: color)

            }
            .frame(alignment: .top)
            .padding(.bottom, 5)
//            .background(Color(UIColor.systemGray5).opacity(0.8))

            .overlay(Rectangle()
                .frame(height: 0.3, alignment: .bottom)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color(UIColor.lightGray)), alignment: .bottom)
            
            
            // paged month view
            ScrollView(.horizontal) {
                LazyHStack(
                    spacing: 0
                ) {
                    ForEach(calendarModel.monthList) { monthModel in
                        MonthView(monthModel: monthModel, isDateSelection: true, selectedDateId: calendarModel.selectedDayId, mainColor: color)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .frame(width: viewWidth)

                    }
                }
                .scrollTargetLayout()
               
            }
            .onAppear {
                monthId = calendarModel.displayMonthId
            }
            .scrollPosition(id: $monthId)
            .onChange(of: monthId) {
                guard let monthId = monthId else { return }
                do {
                    try calendarModel.loadMoreIfNeeded(monthId: monthId, for: userManager.userId)
                } catch(let error) {
                    viewManager.showError(error: error)
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .padding(.vertical, 10)
            
        }
        .padding(.top, 20)
        .modifier(NeumorphismRectangleBackground(color: color))

    }
}

#Preview {
    let viewManager = ViewManager()
    let calendarModel = CalendarModel()
    let userManager = UserManager()
    let themeManager = ThemeManager()

    return GeometryReader { geometry in
        VStack {
            DateSelectionView(viewWidth: geometry.size.width)
        }

    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding(.horizontal, 20)
    .environmentObject(viewManager)
    .environmentObject(calendarModel)
    .environmentObject(userManager)
    .environmentObject(themeManager)
    .task {
        try? await calendarModel.initializeModel(userManager.userId)
        let dayModel = calendarModel.dayList[10]
        calendarModel.selectedDayId = dayModel.id
    }



}
