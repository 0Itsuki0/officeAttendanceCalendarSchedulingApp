//
//  RoundBorder.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/28.
//

import SwiftUI

struct RoundedBorder: ViewModifier {
    var cornerRadius: CGFloat = 16
    var horizontalPadding: CGFloat = 16
    var verticalPadding: CGFloat = 8

    var borderColor: Color
    var backgroundColor: Color = Color.clear
    
    var alignment = Alignment.leading


    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .stroke(borderColor))
    }
}

