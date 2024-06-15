//
//  MonthlyCalendarView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/06.
//


import SwiftUI

struct MonthlyScrollView: View {
    
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var nfcManager: NFCManager


    var animation: Namespace.ID

    @State private var monthId: MonthModel.ID?
    @State private var showMonthLabel: Bool = false
    @State private var isInitial: Bool = true
    
    var body: some View {
        let color = themeManager.color
        let displayedMonthModel = calendarModel.monthModelFromId(monthId ?? calendarModel.idForCurrentMonth())

        VStack(
            alignment: .center,
            spacing: 0
            
        ) {
            // header
            VStack (
                alignment: .center,
                spacing: 10
            ) {
                HStack(spacing: 20) {
                    // year label
                    HStack(
                        alignment: .center,
                        spacing: 10
                    ) {
                        Text(Image(systemName: "star.fill"))
                            .font(.system(size: 15, weight: .bold))
                        Text(displayedMonthModel?.firstDayOfMonth.localizedYear ?? "")
                           .font(.system(size: 20))
                           
                    }

                    Spacer()
                        .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        nfcManager.scan()
                    }, label: {
                        Image(systemName: "barcode.viewfinder")

                    })
                    .font(.system(size: 20, weight: .regular))

                    
                    Button(action: {
                        viewManager.showFullScreenView(.promotionExchange)
                    }, label: {
                        Image(systemName: "p.square")

                    })
                    .font(.system(size: 20, weight: .regular))


                    Button(action: {
                        viewManager.showFullScreenView(.setting)
                    }, label: {
                        Image(systemName: "gearshape")

                    })
                    .font(.system(size: 20, weight: .regular))

                }
                .padding(.horizontal, 20)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .center)

                
                // weekday label
                WeekdayHeaderView(color: color)

            }
            .modifier(HeaderBackground())


            // monthly calendar stack
            ZStack(
                alignment: .top
            ) {
                // month label
                if (showMonthLabel) {
                    
                    Text(displayedMonthModel?.firstDayOfMonth.localizedYearMonth ?? "")
                        .font(.system(size: 20))
                        .fontWeight(Font.Weight.bold)
                        .foregroundStyle(color)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .transition(.opacity)
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .zIndex(2.0)
                }
                
                // scrollable monthly view
                ScrollView {
                    LazyVStack {
                        ForEach(calendarModel.monthList) { monthModel in
                            MonthView(monthModel: monthModel, mainColor: color)
                                .matchedGeometryEffect(id: "DayViewTabBar\(monthModel.id.uuidString)", in: animation)
                        }
                    }
                    .scrollTargetLayout()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .scrollPosition(id: $monthId)
                .padding(.vertical, 10)
                .onAppear{
                    monthId = calendarModel.displayMonthId
                }
                .scrollIndicators(.hidden)
                .onChange(of: monthId, initial: false) {
                    if (monthId == nil) {
                        return
                    }

                    calendarModel.displayMonthId = monthId
                    do {
                        try calendarModel.loadMoreIfNeeded(monthId: monthId!, for: userManager.userId)
                    } catch(let error) {
                        viewManager.showError(error: error)
                    }
                    
                    if (isInitial) {
                        isInitial = false
                        return
                    }
                    
                    showMonthLabel = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.smooth) {
                            showMonthLabel = false
                        }
                    }

                }


            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            
            // footer
            
            HStack {
                Button(action:  {
                    if displayedMonthModel?.id == calendarModel.idForCurrentMonth() {
                        withAnimation {
                            calendarModel.selectedDayId = calendarModel.idForToday()
                        }
                    } else {
                        withAnimation(.linear(duration: 0.3)) {
                            monthId = calendarModel.idForCurrentMonth()
                        }
                    }
                }, label: {
                    Text(Date.localizedTodaySymbol)
                })
                .font(.system(size: 20))
                
                Spacer()
                    .frame(maxWidth: .infinity)

                
                Button(action: {
                    viewManager.showFullScreenView(.addEvent)
                }, label: {
                    Image(systemName: "plus")

                })
                .font(.system(size: 20, weight: .bold))
            }
            .padding(.horizontal, 20)
            .foregroundStyle(color)
            .modifier(FooterBackground())
            
        }
        .onChange(of: nfcManager.errorMessage) {
            guard let message = nfcManager.errorMessage else {return}
            viewManager.showError(message)
            nfcManager.errorMessage = nil
        }
        .onChange(of: nfcManager.processSuccess) {
            guard nfcManager.processSuccess else {return}
            viewManager.showLoader()
            Task {
                do {
                    try await calendarModel.updateEventStatusForUser(userManager.userId, at: nfcManager.location)
                    viewManager.selectedLocationIndex = EventLocation.allCases.firstIndex(of: nfcManager.location) ?? 0
                    viewManager.hideLoader()
                } catch(let error) {
                    viewManager.showError(error: error)
                }
            }
        }
    }
    
}


#Preview {
//    VStack {
//    MonthlyCalendarView()
    @Namespace var animation
    let calendarModel: CalendarModel = CalendarModel()
    let viewManager: ViewManager = ViewManager()
    let themeManager: ThemeManager = ThemeManager()
    let userManager: UserManager = UserManager()
    let nfcManager: NFCManager = NFCManager()

    return MonthlyScrollView(animation: animation)
        .environmentObject(calendarModel)
        .environmentObject(viewManager)
        .environmentObject(themeManager)
        .environmentObject(userManager)
        .environmentObject(nfcManager)
        .task {
            try? await calendarModel.initializeModel(userManager.userId)
            let dayModel = calendarModel.dayList[10]
            calendarModel.selectedDayId = dayModel.id
        }

}

