//
//  LongPressToActionButton.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/29.
//

import SwiftUI

private enum ActionState {
    case initial
    case pressing
    case loading
    case error
    case finish
}

struct IndicatorView: View {

    var progress: CGFloat
    var ringSize: CGFloat
    var lineWidth: CGFloat
    var color: Color
    var shouldSpin: Bool = false

    
    @State private var rotationAngle = -90.0


    var body: some View {
        ZStack {

            // progress
            if !shouldSpin {
                // background
                Circle()
                    .stroke(
                        color.opacity(0.3),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                       
                    )
                    .frame(width: ringSize, height: ringSize)

                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                       
                    )
                    .frame(width: ringSize, height: ringSize)
                
            } else {
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.3)]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                       
                    )
                    .frame(width: ringSize, height: ringSize)

                
                // round cap
                Circle()
                    .frame(width: lineWidth, height: lineWidth)
                    .foregroundColor(color)
                    .offset(x: ringSize/2)
            
            }



        }
        .rotationEffect(.degrees(rotationAngle))
        .onChange(of: shouldSpin){
            if (shouldSpin) {
                rotationAngle = 0
                withAnimation(.linear(duration: 2)
                        .repeatForever(autoreverses: false)) {
                    rotationAngle = 360.0
                }
            } else {
                withAnimation(.linear(duration: 0)) {
                    rotationAngle = -90
                }
            }
        }
    }
    
}




struct LongPressToActionButton: View {
    var actionFunction: () async throws -> Void
    var startImageName: String
    var color: Color
    
    var enabled: Bool

    private let activeTime = 1.5
    private let ringSize: CGFloat = 36
    private let lineWidth: CGFloat = 4
    
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    @State private var state: ActionState = .initial
    @State private var timeRemaining: CGFloat = .infinity

    var body: some View {
        ZStack {
            
            Image(systemName: state == .finish ? "checkmark" : state == .error ? "exclamationmark.triangle" :  startImageName)
                .foregroundStyle(color)
                .font(.system(size: 16, weight: .bold))
                .frame(width: 20, height: 20, alignment: .center)
                .opacity(state == .pressing ? 0.6 : 1)
                .overlay(content: {
                    if !enabled {
                        Image(systemName: "slash.circle")
                            .foregroundStyle(color.opacity(0.8))
                            .font(.system(size: ringSize + lineWidth, weight: .regular))
                    }
                })
                .onLongPressGesture(minimumDuration: activeTime, perform: {
                    guard enabled else {return }
                    guard state == .loading else {return}

                    Task {
                        do {
                            try await actionFunction()
//                            await performAction()
                            DispatchQueue.main.async {
                                state = .finish
                            }
                        } catch(_) {
                            DispatchQueue.main.async {
                                state = .error
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                    state = .initial
                                    timeRemaining = activeTime
                                })
                            }
                        }

                    }
                }, onPressingChanged: { isPressing in
                    guard enabled else {return }

                    if timeRemaining < 0 {
                        if state == .pressing {
                            state = .loading
                        }
                        return
                    }
 
                    if isPressing {
                        state = .pressing
                    } else {
                        state = .initial
                        withAnimation {
                            timeRemaining = activeTime
                        }
                    }
                })

            IndicatorView(progress: (activeTime - timeRemaining) / activeTime, ringSize: ringSize, lineWidth: lineWidth, color: color, shouldSpin: state == .loading)
            

        }
        .onReceive(timer, perform: { _ in
            if state == .pressing {
                if timeRemaining > 0 {
                    withAnimation {
                        timeRemaining = timeRemaining - 0.01
                    }
                }
            }
        })
        .onAppear {
            state = .initial
            timeRemaining = activeTime
        }
    }
    
    func performAction() async {
        sleep(2)
    }
}

#Preview {
    @State var progress: CGFloat = 0

    return LongPressToActionButton(actionFunction: {}, startImageName: "trash", color: Color.blue, enabled: true)

}
