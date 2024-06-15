//
//  PromotionExchangeView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/04.
//

import SwiftUI

struct UserPointsView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var viewManager: ViewManager

    var color: Color
    var onRefreshButtonPress: () -> Void
    var points: Int?
    
    var body: some View {
        HStack(spacing: 30) {
            
            HStack(
                alignment: .center,
                spacing: 10
            ) {
                Image(systemName: "p.square")
                Spacer()
                (Text((points == nil) ? "---" : "\(points!)") + Text(" pt").font(.system(size: 12)))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .frame(minWidth: 200)
            .modifier(RoundedBorder(verticalPadding: 16, borderColor: .clear, backgroundColor: color.opacity(0.3)))
            .frame(maxWidth: .infinity)
            
            Button(action: {
                onRefreshButtonPress()
            }, label: {
                Image(systemName: "arrow.clockwise")
            })
            .padding(.horizontal, 10)

        }
        .font(.system(size: 18))
        .foregroundStyle(color)
        .padding(.horizontal, 20)

    }
}

#Preview {
    @StateObject var viewManager = ViewManager()

    let userManager = UserManager()
    @State var pointsAvailable: Int?

    return UserPointsView(color: .red, onRefreshButtonPress: {}, points: 0)
        .environmentObject(userManager)
        .environmentObject(viewManager)
}
