//
//  InfoEntryView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/28.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var calendarModel: CalendarModel
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var isNew: Bool = true
    @State private var isSlideButtonDisabled: Bool = true
    
    @State private var inputName: String = ""
    @State private var inputId: String = ""
    @State private var inputPassword: String = ""
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isIdFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    var body: some View {
        let color = themeManager.color
        ZStack {
            Image("calendarFrame", bundle: nil)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 600)
                .foregroundStyle(color)

            
            // text field stack
            VStack(
                spacing:30
            ) {
                if isNew {
                    HStack(spacing: 20) {
                       Image(systemName: "person.circle")
                           .font(.system(size: 24))
                        
                        ClearableTextField("User Name", text: $inputName)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .focused($isNameFocused)
                            .font(.system(size: 18))
                            .foregroundStyle(color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .modifier(RoundedBorder(verticalPadding: 6, borderColor: color))
                    }

                }
               
                
                if (!isNew) {
                    HStack(spacing: 20) {
                       Image(systemName: "barcode.viewfinder")
                           .font(.system(size: 24))
                        
                        ClearableTextField("User Id", text: $inputId)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .focused($isIdFocused)
                            .font(.system(size: 18))
                            .foregroundStyle(color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .modifier(RoundedBorder(verticalPadding: 6, borderColor: color))
                    }
                    
                    HStack(spacing: 20) {
                       Image(systemName: "lock")
                           .font(.system(size: 24))
                        
                        ClearableTextField("Password", text: $inputPassword, isSecure: true)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .focused($isPasswordFocused)
                            .font(.system(size: 18))
                            .foregroundStyle(color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .modifier(RoundedBorder(verticalPadding: 6, borderColor: color))
                    }
                    

                }
                
                SlideToActionButton(buttonHeight: 40, color: color, actionFunction: {
                    do {
                        if isNew {
                            try await userManager.registerNewUser(inputName)
                        } else {
                            try await userManager.checkExistingUser(id: inputId, password: inputPassword)
                        }
                        try await calendarModel.initializeModel(userManager.userId)
                        viewManager.initializeFinish()
                    } catch (let error) {
                        viewManager.showError(error: error)
                        throw error
                    }
                }, initialView: Image(systemName: "paperplane.fill"), finishView: Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)))
                .disabled(isSlideButtonDisabled)
                .opacity(isSlideButtonDisabled ? 0.5 : 1)
                
            
                Button(action: {
                    withAnimation {
                        isNew.toggle()
                    }
                }, label: {
                    Text(isNew ? "Returning?" : "New?")
                        .underline(color: color)
                })
                

            }
            .frame(height: 250, alignment: .top)
            .foregroundStyle(color)
            .padding(.all, 40)
            .padding(.top, 100)

            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 10)
        .onChange(of: [inputName, inputId, inputPassword]) {
            isSlideButtonDisabled = isNew ? inputName.trim.isEmpty : (inputPassword.trim.isEmpty || inputId.trim.isEmpty)
        }
        .onChange(of: isNew) {
            isSlideButtonDisabled = isNew ? inputName.trim.isEmpty : (inputPassword.trim.isEmpty || inputId.trim.isEmpty)
        }
        .simultaneousGesture(TapGesture().onEnded({
            isIdFocused = false
            isPasswordFocused = false
            isNameFocused = false
        }), including: .all)
        .simultaneousGesture(DragGesture().onChanged({ _ in
            isIdFocused = false
            isPasswordFocused = false
            isNameFocused = false
        }), including:.all)
    }
}


#Preview {
    @StateObject var calendarModel = CalendarModel()
    @StateObject var viewManager = ViewManager()
    @StateObject var themeManager = ThemeManager()
    @StateObject var userManager = UserManager()

    return LoginView()
        .environmentObject(calendarModel)
        .environmentObject(viewManager)
        .environmentObject(userManager)
        .environmentObject(themeManager)

}
