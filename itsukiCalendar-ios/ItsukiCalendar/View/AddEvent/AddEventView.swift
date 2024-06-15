//
//  EventAddView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/21.
//

import SwiftUI

struct AddEventView: View {
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager

    private let eventLocations = EventLocation.allCases
    
    var body: some View {
        let color = themeManager.color
        
        GeometryReader { geometry in
            let menuWidth = geometry.size.width - 100

            VStack(spacing: 0) {
                
                HStack {
                    Button(action: {
                        viewManager.hideFullScreenView()
                    }, label: {
                        Image(systemName: "xmark")

                    })
                    .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                        .frame(maxWidth: .infinity)

                    Button(action: {
                        viewManager.showLoader()
                        Task {
                            do {
                                try await calendarModel.addEventForUser(userManager.userId, location: eventLocations[viewManager.selectedLocationIndex])
                                viewManager.hideLoader()
                                viewManager.hideFullScreenView()
                            } catch(let error) {
                                viewManager.showError(error: error)
                            }
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .font(.system(size: 20, weight: .bold))
                }
                .foregroundStyle(color)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .modifier(HeaderBackground())

                Spacer()
                    .frame(height: 25)

                // location selection
                let locationOptionString = eventLocations.map{$0.title}
                HStack(spacing: 20) {
                   Image(systemName: "mappin.and.ellipse.circle")
                       .font(.system(size: 24))

                    DropDownMenu(options: locationOptionString, mainColor: color, menuWidth: menuWidth,
                                 maxItemDisplayed: 4, selectedOptionIndex: $viewManager.selectedLocationIndex, showDropdown: $viewManager.addEventLocationDropdown)
                    
                    .font(.system(size: 18))
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(color)
                .zIndex(100)
                
                
                Spacer()
                    .frame(height: 20)
            
                
                // date label
                HStack(spacing: 20) {
                   Image(systemName: "calendar.badge.plus")
                       .font(.system(size: 24))
                    
                    let dayModel = calendarModel.dayModelFromId(calendarModel.selectedDayId ?? UUID())
                    Text(dayModel?.date.localizedDate ?? "")
                        .font(.system(size: 18))
                        .foregroundStyle(color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .modifier(RoundedBorder(borderColor: color))
                }
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity)
                .foregroundStyle(color)
                
                
                Spacer()
                    .frame(height: 20)

                // date selection
                DateSelectionView(viewWidth: geometry.size.width - 40)
                    .padding(.horizontal, 20)
                
            }
        }
        .onAppear {
            if calendarModel.selectedDayId == nil {
                if let displayMonthId = calendarModel.displayMonthId {
                    let monthModel = calendarModel.monthModelFromId(displayMonthId)
                    if monthModel?.id == calendarModel.idForCurrentMonth() {
                        calendarModel.selectedDayId = calendarModel.idForToday()
                        return
                    }
                    let modelForFirstDay = monthModel?.modelForFirstDay()
                    if let modelForFirstDay = modelForFirstDay {
                        calendarModel.selectedDayId = modelForFirstDay.id
                    } else {
                        calendarModel.selectedDayId = calendarModel.idForToday()

                    }
                } else {
                    calendarModel.selectedDayId = calendarModel.idForToday()
                }
            }
        }
        .simultaneousGesture(TapGesture().onEnded({
            viewManager.hideAddEventLocationDropDown()
        }), including: viewManager.addEventLocationDropdown ? .all : .subviews)
        .simultaneousGesture(DragGesture().onChanged({_ in
            viewManager.hideAddEventLocationDropDown()

        }), including: viewManager.addEventLocationDropdown ? .all : .subviews)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onDisappear {
            viewManager.addEventLocationDropdown = false
        }

    }
}


#Preview {
    let viewManager = ViewManager()
    let calendarModel = CalendarModel()
    let userManager = UserManager()
    let themeManager = ThemeManager()

    return AddEventView()
       .environmentObject(viewManager)
       .environmentObject(calendarModel)
       .environmentObject(userManager)
       .environmentObject(themeManager)
       .frame(maxWidth: .infinity, maxHeight: .infinity)
       .task {
           try? await calendarModel.initializeModel(userManager.userId)
           let dayModel = calendarModel.dayList[10]
           calendarModel.selectedDayId = dayModel.id
       }


}

