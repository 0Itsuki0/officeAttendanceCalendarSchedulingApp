//
//  BackgroundModifier.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/28.
//

import SwiftUI


struct HeaderBackground: ViewModifier {

    func body(content: Content) -> some View {
        content
            .frame(alignment: .top)
            .padding(.bottom, 10)
            .background(Color(UIColor.systemGray5).opacity(0.6))
            .overlay(Rectangle()
                .frame(height: 0.5, alignment: .bottom)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color(UIColor.lightGray)), alignment: .bottom)
    }
}


struct FooterBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 40)
            .padding(.top, 10)
            .background(Color(UIColor.systemGray5).opacity(0.6))
            .overlay(Rectangle()
                .frame(height: 0.5, alignment: .top)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color(UIColor.lightGray)), alignment: .top)    }
}


struct NeumorphismRectangleBackground: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: color.opacity(0.2), radius: 5, x: 2, y: 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            )
    }
}
