//
//  SlideToButton.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/16.
//

import SwiftUI

private enum ActionState {
    case initial
    case loading
    case error
    case finish
}


private struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(1)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.default, value: configuration.isPressed)
    }
}

private struct DraggableView<InitialView: View, FinishView: View>: View {
    
    let maxDraggableWidth: CGFloat
    let color: Color
    let actionFunction: () async throws -> Void
    
    let leadingView: InitialView
    let finishView: FinishView

    var minWidth: CGFloat = 40
    @State var width: CGFloat = 40


    @State fileprivate var actionState: ActionState = ActionState.initial
    

    private let startingOpacity: Double = 0.2
    private let imagePadding: CGFloat = 4
    
    
    var body: some View {
        let opacity: Double = (width/maxDraggableWidth)
        RoundedRectangle(cornerRadius: 16)
            .fill(color.opacity(opacity))
              .frame(width: width)
              .overlay(
                Button(action: {}, label: {
                    switch actionState {
                    case .initial:
                        leadingView
                    case .loading:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: color))
                    case .error:
                         Image(systemName: "exclamationmark.circle")
                    case .finish:
                        finishView
                    }
                })
                .buttonStyle(CustomButtonStyle())
                .disabled(actionState != .initial)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundStyle(color)
                .frame(width: minWidth - 2 * imagePadding, height: minWidth - 2 * imagePadding)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color, lineWidth: 4)
                        .fill(.white)
                )
                .padding(.all, imagePadding),
                alignment: .trailing
              )
              .highPriorityGesture(
                DragGesture()
                  .onChanged { value in
                      guard (actionState == .initial) else {return}
                      if value.translation.width > 0 {
                            width = min(value.translation.width  + minWidth, maxDraggableWidth)
                        }
                    }
                    .onEnded {_ in
                        guard (actionState == .initial) else {return}
                        
                        if width < maxDraggableWidth {
                            width = minWidth
                            return
                        }
                        withAnimation(.spring().delay(0.5)) {
                            actionState = .loading
                        }

                        Task {
                            do {
                                try await actionFunction()
                                DispatchQueue.main.async {
                                    actionState = .finish
                                }
                            } catch(_) {
                                DispatchQueue.main.async {
                                    actionState = .error
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                        actionState = .initial
                                        width = minWidth
                                    })
                                }
                            }
                        }
                    }
              )
              .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: width)
    }
}

private struct BackgroundView: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(color.opacity(0.4))
            .overlay(
                HStack {
                    Image(systemName: "chevron.right.2" )
                    Image(systemName: "chevron.right.2")
                }
                    .phaseAnimator([0, 1], content: {view, phase in
                        view
                            .offset(x: phase * 10)
                    }, animation: {phase in
                            .linear(duration: 0.8)
                    })
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.6)),
                alignment: .center
                    
            )
    }
}

struct SlideToActionButton<InitialView: View, FinishView: View>: View {

    var buttonHeight: CGFloat = 40
    let color: Color
    let actionFunction: () async throws -> Void
    
    let initialView: InitialView
    let finishView: FinishView

    var body: some View {

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                BackgroundView(color: color)
                DraggableView(maxDraggableWidth: geometry.size.width, color: color, actionFunction: actionFunction, leadingView: initialView, finishView: finishView, minWidth: buttonHeight, width: buttonHeight )
            }
        }
        .frame(height: buttonHeight)
    }
}


#Preview {
    func mySleep() async {
        sleep(2)
    }
    let actionFunction: () async -> Void = {
        await mySleep()
    }
    return SlideToActionButton(
        color: .red,
        actionFunction: actionFunction,
        initialView: Image(systemName: "lock"),
        finishView: Image(systemName: "lock.open")
        )
        .padding(.horizontal, 50)

}

