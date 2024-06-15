//
//  PromotionExchangeView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/04.
//

import SwiftUI

struct PromotionExchangeView: View {
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager

    @Namespace var exchangeAnimation

    @State private var promotionExchanged: PromotionType? = nil
    @State private var promotionCode: String? = nil

    @State private var pointsAvailable: Int?
    @State private var promotionCount: PromotionCount = PromotionCount()
    
    private let promotionTypes = PromotionType.allCases
    
    var body: some View {
        let color: Color = themeManager.color
        ZStack{
            if promotionExchanged == nil {
                
                VStack(spacing:0) {
                    // header
                    HStack {
                        Button(action: {
                            viewManager.hideFullScreenView()
                        }, label: {
                            Image(systemName: "xmark")

                        })
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "storefront")
                            Image(systemName: "ellipsis")
                            Image(systemName: "ellipsis")
                            Image(systemName: "ellipsis")
                            Image(systemName: "ellipsis")
                            Image(systemName: "storefront")
                        }
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .foregroundStyle(color)
                    .modifier(HeaderBackground())

                    Spacer()
                        .frame(height: 10)
                    
                    ScrollView(.vertical) {
                        
                        Spacer()
                            .frame(height: 20)


                        UserPointsView(color: color, onRefreshButtonPress: {
                            viewManager.showLoader()
                            Task {
                                do {
                                    try await load()
                                    viewManager.hideLoader()
                                } catch (let error) {
                                    viewManager.showError(error: error)
                                }
                            }
                        }, points: pointsAvailable)

                        Spacer()
                            .frame(height: 30)

                        VStack (spacing: 30) {
                            ForEach(promotionTypes, id: \.self) { type in
                                ExchangeCardView(
                                    exchangeAnimation: exchangeAnimation,
                                    promotionType: type, count: promotionCount.count(type), color: color,
                                    exchangeEnabled: (pointsAvailable ?? 0) >= Constants.PromotionConstants.exchangePoints,
                                    onExchangeButtonPressed: {
                                        do {
                                            let code = try await PromotionManager.exchangePromotion(type, for: userManager.userId)
                                            
                                            try await load()

                                            promotionCode = code
                                            withAnimation(.linear(duration: 0.4)) {
                                                promotionExchanged = type
                                            }
                                        } catch (let error) {
                                            viewManager.showError()
                                            throw error
                                        }

                                    }
                               )

                            }
                        }
            
                    }

                }
                
            } else {
                ExchangeFinishView(exchangeAnimation: exchangeAnimation, color: color, promotionExchanged: $promotionExchanged, promotionCode: $promotionCode)
            }
        
        }
        .task {
            viewManager.showLoader()
            do {
                try await load()
                viewManager.hideLoader()
            } catch (let error) {
                viewManager.showError(error: error)
            }
        }

    }
    
    
    private func load() async throws {
        self.pointsAvailable = try await userManager.getUserPoints()
        self.promotionCount = try await PromotionManager.getPromotionCount()
    }
}

#Preview {
    
    let viewManager = ViewManager()
    let themeManager = ThemeManager()
    let userManager = UserManager()

    return PromotionExchangeView()
        .environmentObject(viewManager)
        .environmentObject(themeManager)
        .environmentObject(userManager)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
