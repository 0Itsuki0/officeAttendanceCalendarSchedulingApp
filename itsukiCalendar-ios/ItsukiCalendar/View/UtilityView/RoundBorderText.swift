//
//  TextWithRoundBorder.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/20.
//

import SwiftUI

struct RoundBorderText: View  {
    var text: String
    
    var font: Font = Font(UIFont.systemFont(ofSize: 18))
    var cornerRadius: CGFloat = 16
    var horizontalPadding: CGFloat = 16
    var verticalPadding: CGFloat = 6
    
    var lineLimit: Int = 1
    var mainColor: Color
    var colorReversed: Bool = false
    
    var leadingImage: Image? = nil
    var trailingImage: Image? = nil
    var imageSize: CGSize = CGSize(width: 12, height: 12)
    
    var body: some View {
        HStack(spacing: 12){
            leadingImage?
                .font(.system(size: 14, weight: .bold))
            
            Text(text)
            
            trailingImage?
                .font(.system(size: 14, weight: .bold))


        }
        .font(font)
        .foregroundStyle(colorReversed ? Color.white : mainColor)
        .lineLimit(lineLimit)
        .modifier(RoundedBorder(cornerRadius: cornerRadius, horizontalPadding: horizontalPadding, verticalPadding: verticalPadding, borderColor: colorReversed ? Color.clear : mainColor, backgroundColor: colorReversed ? mainColor : Color.clear))

    }
}


#Preview {
    return RoundBorderText(text: "test", mainColor: Color.red, colorReversed: true, trailingImage: Image(systemName: "questionmark"))
}
