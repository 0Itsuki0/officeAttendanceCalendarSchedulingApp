//
//  DropDownMenu.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/20.
//

import SwiftUI

struct DropDownMenu: View {
    
    var options: [String]
    var mainColor: Color

    var menuWidth: CGFloat = 150
    var buttonHeight: CGFloat = 38
    var maxItemDisplayed: Int = 3
    
    var horizontalPadding: CGFloat = 16

    @Binding var selectedOptionIndex: Int
    @Binding var showDropdown: Bool
    
    @State private var scrollPosition: Int?

    var body: some View {
        
        VStack {

            VStack(spacing: 0) {
                // selected item
                Button(action: {
                    withAnimation {
                        showDropdown = true
                    }
                }, label: {
                    HStack(spacing: nil) {
                        Text(options[selectedOptionIndex])
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                    }

                })
                .padding(.horizontal, horizontalPadding)
                .frame(width: menuWidth, height: buttonHeight, alignment: .leading)

                
                // selection menu
                if (showDropdown) {
                    let scrollViewHeight: CGFloat = options.count > maxItemDisplayed ? (buttonHeight*CGFloat(maxItemDisplayed)) : (buttonHeight*CGFloat(options.count))
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<options.count, id: \.self) { index in
                                
                                Button(action: {
                                    withAnimation {
                                        selectedOptionIndex = index
                                        showDropdown = false
                                    }

                                }, label: {
                                    HStack {
                                        Text(options[index])
                                        Spacer()
                                        if (index == selectedOptionIndex) {
                                            Image(systemName: "checkmark.circle.fill")

                                        }
                                    }
                                
                                })
                                .padding(.horizontal, 16)
                                .frame(width: menuWidth, height: buttonHeight, alignment: .leading)

                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $scrollPosition)
                    .scrollDisabled(options.count <= 3)
                    .frame(height: scrollViewHeight)
                    .onAppear {
                        scrollPosition = selectedOptionIndex
                    }
                
                }
                
            }
            .foregroundStyle(mainColor)
            .background(
                RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .stroke(mainColor, style: StrokeStyle())
            )
            
        }
        .frame(width: menuWidth, height: buttonHeight, alignment: .top)
        .zIndex(100)
        
    }
}
