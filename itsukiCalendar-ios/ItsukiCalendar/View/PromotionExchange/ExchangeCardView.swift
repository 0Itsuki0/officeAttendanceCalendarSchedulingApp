//
//  CouponView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/04.
//

import SwiftUI

struct ExchangeCardView: View {

    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userManager: UserManager

    var exchangeAnimation: Namespace.ID
    var promotionType: PromotionType
    var count: Int
    var color: Color
    var exchangeEnabled: Bool

    var onExchangeButtonPressed: () async throws -> Void

    var body: some View {
        VStack{
            Text(promotionType.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title3)
                .matchedGeometryEffect(id: "\(promotionType)ExchangeTitle", in: exchangeAnimation, properties: .position, isSource: true)

            
            Spacer()

            HStack{
                Image("\(promotionType)", bundle: nil)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .matchedGeometryEffect(id: "\(promotionType)ExchangeImage", in: exchangeAnimation, properties: .position, isSource: true)

                
                Spacer()
                
                VStack(spacing: 20) {
                    HStack {
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "p.square")
                                Text("\(Constants.PromotionConstants.exchangePoints)")
                            }
                            
                            Image(systemName: "arrow.up.arrow.down")
                            
                            HStack {
                                Image(systemName: "yensign.square")
                                Text("\(Constants.PromotionConstants.promotionValue)")
                            }
                        }

                    }
                }
                
                Spacer()
                
                if count == 0 {
                    Image(systemName: "truck.box.badge.clock")
                } else {
                    LongPressToActionButton(actionFunction: {
                        try await onExchangeButtonPressed()
                    }, startImageName: "yensign.arrow.circlepath", color: color, enabled: exchangeEnabled)

                }
            }

        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
        .frame(height: 210)
        .modifier(NeumorphismRectangleBackground(color: color))
        .matchedGeometryEffect(id: "\(promotionType)ExchangeFrame", in: exchangeAnimation, properties: .size, isSource: true)
        .opacity(count == 0 ? 0.7 : 1)
        .padding(.horizontal, 20)

    }
}


#Preview {
    let viewManager = ViewManager()
    let themeManager = ThemeManager()
    let userManager = UserManager()
    @Namespace var animation

    return ExchangeCardView(exchangeAnimation: animation, promotionType: .apple, count: 100, color: .red, exchangeEnabled: true, onExchangeButtonPressed: {})
        .environmentObject(viewManager)
        .environmentObject(userManager)
        .environmentObject(themeManager)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.gray.opacity(0.2))
}
