//
//  WeekdayHeaderView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/21.
//

import SwiftUI

struct WeekdayHeaderView: View {
    var color: Color
    
    var body: some View {
        HStackWithPadding {
            let weekdaySymbols = Date.weekdaySymbols
            ForEach(0..<weekdaySymbols.count, id: \.self) { i in
                let symbol = weekdaySymbols[i]
                Text(symbol)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(size: 16))
                    .padding(.all, 5)
                    .foregroundStyle((i == 0 || i == 6) ? color : Color.black)
            }
            
        }
    }
}


#Preview {
    WeekdayHeaderView(color: .red)
}
