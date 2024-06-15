//
//  UserNameEntryView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/27.
//

import SwiftUI

struct NameChangeView: View {
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @Binding var showNameChangeView: Bool
    
    @State private var isSlideButtonDisabled: Bool = true
    @State private var inputName: String = ""
    @FocusState private var isNameFocused: Bool
    

    var body: some View {
        let color = themeManager.color
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.7))
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showNameChangeView = false
                    }
                }
            
            VStack(
                spacing:30
            ) {
                    
                TextField("User Name", text: $inputName)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .focused($isNameFocused)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(RoundedBorder(verticalPadding: 6, borderColor: color))


                SlideToActionButton(buttonHeight: 40, color: color, actionFunction: {
                    do {
                        try await userManager.changeUserName(inputName)
                        DispatchQueue.main.async {
                            withAnimation {
                                showNameChangeView = false
                            }
                        }
                    } catch (let error) {
                        viewManager.showError()
                        throw error
                    }
                }, initialView: Image(systemName: "paperplane.fill"), finishView: Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)))
                .disabled(isSlideButtonDisabled)
                .opacity(isSlideButtonDisabled ? 0.5 : 1)
                
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .padding(.top, 60)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .overlay (alignment: .topTrailing, content: {
                Button(action: {
                    withAnimation {
                        showNameChangeView = false
                    }
                }, label: {
                    Image(systemName: "xmark")
                        .padding(.all, 20)
                        .fontWeight(.bold)
                })
            })
            .padding(.horizontal, 40)
            .foregroundStyle(color)
        }

        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onChange(of: [inputName]) {
            isSlideButtonDisabled = inputName.isEmpty
        }
        .simultaneousGesture(TapGesture().onEnded({
            isNameFocused = false
        }), including: .all)
        .simultaneousGesture(DragGesture().onChanged({ _ in
            isNameFocused = false
        }), including:.all)

    }
}

#Preview {
    @StateObject var viewManager = ViewManager()
    @StateObject var themeManager = ThemeManager()
    @StateObject var userManager = UserManager()

    @State var showNameChangeView: Bool = true
    return NameChangeView(showNameChangeView: $showNameChangeView)
        .environmentObject(viewManager)
        .environmentObject(userManager)
        .environmentObject(themeManager)

}
