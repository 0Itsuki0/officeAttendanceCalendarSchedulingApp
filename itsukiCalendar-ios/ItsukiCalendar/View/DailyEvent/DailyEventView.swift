//
//  DayEventView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/07.
//

import SwiftUI


struct DailyEventView: View {
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var nfcManager: NFCManager
    @EnvironmentObject var themeManager: ThemeManager

    var animation: Namespace.ID

    var body: some View {
        let color = themeManager.color

        let selectedDayModel = calendarModel.dayModelFromId(calendarModel.selectedDayId ?? UUID())

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
                    // month label
                    Button(action: {
                        withAnimation {
                            calendarModel.selectedDayId = nil
                        }
                    }, label: {
                        HStack(
                            alignment: .center,
                            spacing: 10
                        ) {
                            Text(Image(systemName: "chevron.left"))
                                .font(.system(size: 15, weight: .bold))
                            Text(selectedDayModel?.date.localizedMonth ?? "")
                               .font(.system(size: 20))
                        }
                    })

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

                
                VStack (
                    alignment: .center,
                    spacing: -3
                ) {
                    // weekday label
                    WeekdayHeaderView(color: color)
                    
                    // days label
                    DayViewTabBar(mainColor: color)
                        .matchedGeometryEffect(id: "DayViewTabBar\(calendarModel.displayMonthId?.uuidString ?? "")", in: animation)
                    
                    // date label
                    Text("\(selectedDayModel?.date.localizedDateWithWeekday ?? "")")

                }
            }
            .modifier(HeaderBackground())

            
                
            // paged weekly tab bar
            PagedEventView()

            
            // footer
            HStack {
                Button(action:  {
                    withAnimation(.linear(duration: 0.3)) {
                        calendarModel.selectedDayId = calendarModel.idForToday()
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
        .onTapGesture {
            viewManager.hideViewEventLocationDropDown()
        }
        .simultaneousGesture(TapGesture().onEnded({
            withAnimation {
                viewManager.viewEventLocationDropdown = false
            }
        }), including: viewManager.viewEventLocationDropdown ? .all : .subviews)
        .simultaneousGesture(DragGesture().onChanged({_ in
            withAnimation {
                viewManager.viewEventLocationDropdown = false
            }
        }), including: viewManager.viewEventLocationDropdown ? .all : .subviews)
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
        .onAppear {
            guard let dayId = calendarModel.selectedDayId else { return }
            viewManager.showLoader()

            Task {
                do {
                    try await calendarModel.fetchOfficeState(dayId, currentUserId: userManager.userId)
                    viewManager.hideLoader()
                } catch (let error) {
                    viewManager.showError(error: error)
                }
            }
        }
        .onChange(of: calendarModel.selectedDayId) {

            guard let dayId = calendarModel.selectedDayId else { return }
            do {
                try calendarModel.loadMoreIfNeeded(dayId: dayId, for: userManager.userId)
            } catch(let error) {
                viewManager.showError(error: error)
            }
            viewManager.showLoader()

            Task {
                do {
                    try await calendarModel.fetchOfficeState(dayId, currentUserId: userManager.userId)
                    viewManager.hideLoader()
                } catch (let error) {
                    viewManager.showError(error: error)
                }
            }

        }
    }
    
}


#Preview {

    let calendarModel: CalendarModel = CalendarModel()
    let viewManager: ViewManager = ViewManager()
    let themeManager: ThemeManager = ThemeManager()
    let userManager: UserManager = UserManager()
    let nfcManager: NFCManager = NFCManager()
    @Namespace var animation

    return DailyEventView(animation: animation)
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

