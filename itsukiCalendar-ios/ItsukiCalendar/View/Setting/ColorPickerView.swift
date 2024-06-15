//
//  ColorPickerView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/28.
//

import SwiftUI


struct ColorPickerView: View {
    @EnvironmentObject var themeManager: ThemeManager

    private let colorThemes = Theme.allCases

    var body: some View {
        let color = themeManager.theme.color

        VStack(spacing: 20) {
            ForEach(0..<3) { row in
                HStack {
                    ForEach(0..<3) { index in
                        if index != 0 {
                            Spacer().frame(maxWidth: .infinity)
                        }
                        let colorTheme = colorThemes[row * 3 + index]
                        
                        Button(action: {
                            withAnimation {
                                themeManager.setTheme(colorTheme)
                            }
                        }, label: {
                            ColorView(color: colorTheme.color, selected: colorTheme == themeManager.theme )
                        })
                    }

                }
            }

        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 50)
        .modifier(NeumorphismRectangleBackground(color: color))
        .overlay(
            VStack {
                HStack {
                    Image(systemName: "paintpalette")
                    Spacer().frame(maxWidth: .infinity)
                    Image(systemName: "paintpalette")
                }
                Spacer().frame(maxHeight: .infinity)
                HStack {
                    Image(systemName: "paintpalette")
                    Spacer().frame(maxWidth: .infinity)
                    Image(systemName: "paintpalette")
                }

            }
            .padding(.all, 5)
            .foregroundStyle(color)
            .font(.system(size: 18, weight: .bold)),
            alignment: .top
        )
        .padding(.horizontal, 20)
    }
}

private struct ColorView: View {
    let color: Color
    let selected: Bool
    
    var body: some View {
        let gradient = RadialGradient(colors: [color.opacity(0.3), color.opacity(0.9)], center: UnitPoint(x: 0.6, y: 0.4), startRadius: 0, endRadius: 15)
        Circle()
            .fill(gradient)
            .frame(width: 40)
            .padding(.all, 10)
            .background(
                Circle()
                    .fill(Color.white)
                    .shadow(color: selected ? color.opacity(0.8) : Color.clear, radius: 3, x: 1, y: 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            )
    }
}



#Preview {
    @StateObject var viewManager = ViewManager()
    let calendar = CalendarModel()

    let themeManager = ThemeManager()
    let userManager = UserManager()

    return ColorPickerView()
        .environmentObject(viewManager)
        .environmentObject(calendar)
        .environmentObject(themeManager)
        .environmentObject(userManager)

}
