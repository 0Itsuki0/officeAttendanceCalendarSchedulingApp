//
//  SettingView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/22.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    
    @State private var showNameChangeView: Bool = false
    @State private var showSyncInfoView: Bool = false
    @State private var syncPassword: String = ""

    @State private var showUpdateIconClearView: Bool = false

    private let colorThemes = Theme.allCases
    
    var body: some View {
        let color = themeManager.color
        
        ZStack {
            GeometryReader { geometry in

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
                            Image(systemName: "gearshape")
                            Image(systemName: "ellipsis")
                            Image(systemName: "ellipsis")
                            Image(systemName: "ellipsis")
                            Image(systemName: "ellipsis")
                            Image(systemName: "gearshape")
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
                        .frame(height: 60)
                    
                    
                    // user info
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                           Image(systemName: "person.circle")
                               .font(.system(size: 24))
                            
                            HStack {
                                Text(userManager.userName)
                                    .lineLimit(1)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        showNameChangeView = true
                                    }
                                }, label: {
                                    Image(systemName: "square.and.pencil")
                                })
                            }
                            .font(.system(size: 18))
                            .foregroundStyle(color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .modifier(RoundedBorder(borderColor: color))
                        }
                        
                        HStack(spacing: 20) {
                           Image(systemName: "barcode.viewfinder")
                               .font(.system(size: 24))
                            
                            HStack{
                                Text(userManager.userId)
                                    .lineLimit(1)
                                Spacer()
                                Button(action: {
                                    viewManager.showLoader()
                                    Task {
                                        do {
                                            self.syncPassword = try await userManager.requestSyncPassword()
                                            viewManager.hideLoader()
                                            DispatchQueue.main.async {
                                                withAnimation {
                                                    showSyncInfoView = true
                                                }
                                            }
                                        } catch (let error) {
                                            viewManager.showError(error: error)
                                        }
                                    }
                                    
                                }, label: {
                                    Image(systemName: "link")
                                })
                            }
                            .font(.system(size: 18))
                            .foregroundStyle(color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .modifier(RoundedBorder(borderColor: color))

                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(color)
                    .padding(.horizontal, 40)


                    Spacer()
                        .frame(height: 60)
                    
                    ColorPickerView()

                    Spacer()
                        .frame(height: 90)
                
                    SettingFooterView(color: color)
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .fullScreenCover(isPresented: $showUpdateIconClearView) {
                ClearView()
            }
            .onChange(of: themeManager.theme) {
                showUpdateIconClearView = true
                viewManager.showLoader()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
                    showUpdateIconClearView = false
                    viewManager.hideLoader()
                }
            }
            .onChange(of: themeManager.errorMessage) {
                guard let message = themeManager.errorMessage else {return}
                viewManager.showError(message)
                themeManager.errorMessage = nil
            }
            
            if (showNameChangeView) {
                NameChangeView(showNameChangeView: $showNameChangeView)
            }
            
            if (showSyncInfoView) {
                SyncInfoView(color: color, password: self.syncPassword, showSyncInfoView: $showSyncInfoView)
            }
            
        }
    }
}


private struct ClearView: View {
    var body: some View {
        Color.clear
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationBackground(Color.clear)
            .foregroundStyle(Color.clear)

    }
}



#Preview {
    @StateObject var viewManager = ViewManager()
    @StateObject var calendar = CalendarModel()
    @StateObject var  themeManager = ThemeManager()
    @StateObject var  userManager = UserManager()

    return SettingView()
       .environmentObject(viewManager)
       .environmentObject(calendar)
       .environmentObject(themeManager)
       .environmentObject(userManager)
       .frame(maxWidth: .infinity, maxHeight: .infinity)



}

