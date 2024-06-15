//
//  HStackWithPadding.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/07.
//

import SwiftUI


struct HStackWithPadding<Content>: View where Content: View  {

    var leadingPadding: CGFloat = 10
    var trailingPadding: CGFloat = 10

    @ViewBuilder var content: Content
    
    var body: some View {
        HStack(
            alignment: .center
        ) {
            Spacer()
                .frame(width: leadingPadding, height: 10, alignment: .center)
            content
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
                .frame(width: trailingPadding, height: 10, alignment: .center)
        }
    }
}
