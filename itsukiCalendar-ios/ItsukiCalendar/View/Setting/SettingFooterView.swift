//
//  SettingFooterView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/28.
//

import SwiftUI

struct SettingFooterView: View {
    var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .rotationEffect(Angle(degrees: 320))
            Spacer().frame(maxWidth: .infinity)

            Image(systemName: "calendar")
                .rotationEffect(Angle(degrees: 20))
            Spacer().frame(maxWidth: .infinity)

            Image(systemName: "calendar")
                .rotationEffect(Angle(degrees: 320))
            Spacer().frame(maxWidth: .infinity)

            Image(systemName: "calendar")
                .rotationEffect(Angle(degrees: 20))
            Spacer().frame(maxWidth: .infinity)

            Image(systemName: "calendar")
                .rotationEffect(Angle(degrees: 320))
            Spacer().frame(maxWidth: .infinity)

            Image(systemName: "calendar")
                .rotationEffect(Angle(degrees: 20))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 20)
        .font(.system(size: 24))
        .foregroundStyle(color)
    }
}
