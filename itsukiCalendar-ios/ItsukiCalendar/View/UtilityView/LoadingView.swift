//
//  Loader.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/19.
//

import SwiftUI

struct LoadingView: View {
    @State private var rotationAngle = 0.0
    private let ringSize: CGFloat = 80

    var colors: [Color]

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.7))
                .ignoresSafeArea()
            
            ZStack {
                Circle()
                   .stroke(
                       AngularGradient(
                           gradient: Gradient(colors: colors),
                           center: .center,
                           startAngle: .degrees(0),
                           endAngle: .degrees(360)
                       ),
                       style: StrokeStyle(lineWidth: 16, lineCap: .round)
                       
                   )
                   .frame(width: ringSize, height: ringSize)

                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(colors[0])
                    .offset(x: ringSize/2)

            }
            .rotationEffect(.degrees(rotationAngle))
            .padding(.horizontal, 80)
            .padding(.vertical, 50)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .onAppear {
                withAnimation(.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)) {
                        rotationAngle = 360.0
                    }
            }
            .onDisappear{
                rotationAngle = 0.0
            }
        }

        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}



#Preview {
    let colors: [Color] = [Color.red, Color.red.opacity(0.3)]
    return LoadingView(colors: colors)
}
