//
//  OfficeStateView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/21.
//

import SwiftUI

struct OfficeStateView: View {

    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager

    var events: [EventRecord]
    private let eventLocations = EventLocation.allCases
    
    var body: some View {
        let color = themeManager.color

        GeometryReader { geometry in
            let width = geometry.size.width

            VStack(spacing: 0) {

                let locationOptionStrings = eventLocations.map{$0.title}
                HStack(spacing: 20) {
                   Image(systemName: "mappin.and.ellipse.circle")
                       .font(.system(size: 24))

                    DropDownMenu(options: locationOptionStrings, mainColor: color, menuWidth: width - 80,
                                 maxItemDisplayed: 4, selectedOptionIndex: $viewManager.selectedLocationIndex, showDropdown: $viewManager.viewEventLocationDropdown)
                    .font(.system(size: 18))
                }
                .foregroundStyle(color)
                .zIndex(100)
                
                Spacer().frame(height: 20)
                
                let location = eventLocations[viewManager.selectedLocationIndex]
                let eventAtLocation = events.filter({$0.location == location })
                
                Group {
                    if (eventAtLocation.isEmpty) {
                        Image("noEvent", bundle: nil)
                            .resizable()
                            .scaledToFit()
                            .frame( height: 230)
                            .padding(.all, 20)
                    }
                    else {
                        let currentUserIndex = eventAtLocation.firstIndex(where: {$0.userId == userManager.userId})
                        CollectionView(items: eventAtLocation, selectedItemIndex: currentUserIndex,
                                       containerWidth: width - 20, mainColor: color)
                            .padding(10)
                    }

                }
                .padding(.all, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .modifier(NeumorphismRectangleBackground(color: color))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

    }
}
