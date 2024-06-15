//
//  CardShareView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/05.
//

import SwiftUI

struct ShareCardView: View {

    var color: Color
    var promotionType: PromotionType
    var promotionCode: String
    
    var body: some View {
        VStack {
            
            Image("\(promotionType)", bundle: nil)
                .resizable()
                .frame(width: 90, height: 90)
                .overlay(alignment: .topTrailing, content: {
                    HStack(spacing:2) {
                        Image(systemName: "yensign")
                            .font(.system(size: 12))
                        Text("\(Constants.PromotionConstants.promotionValue)")
                    }
                    .offset(x: 70, y: 0)
                })

            Spacer()
            
            HStack(spacing: 20) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 24))
                
                Text(promotionCode)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .modifier(RoundedBorder(borderColor: color))
            }
            
        
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 40)
        .padding(.vertical, 40)
        .frame(width: 350, height: 240, alignment: .center)
        .modifier(NeumorphismRectangleBackground(color: color))
        .padding(.all, 20)
    }
}


#Preview {

    return ShareCardView(color: .red, promotionType: .apple, promotionCode: "some-d---dddd")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.gray.opacity(0.2))
}
