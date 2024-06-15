//
//  SyncInfoView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/28.
//

import SwiftUI

struct SyncInfoView: View {
    var color: Color
    var password: String
    
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userManager: UserManager
    @Binding var showSyncInfoView: Bool

    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.7))
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showSyncInfoView = false
                    }
                }
            
            VStack(
                spacing:30
            ) {
                    
                HStack(spacing: 20) {
                   Image(systemName: "barcode.viewfinder")
                       .font(.system(size: 24))
                    
                    HStack {
                        Text(userManager.userId)
                        Spacer()
                        Button(action: {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = userManager.userId

                        }, label: {
                            Image(systemName: "doc.on.doc")
                        })
                    }
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(RoundedBorder(borderColor: color))
                }
                
                HStack(spacing: 20) {
                   Image(systemName: "lock")
                       .font(.system(size: 24))
                    
                    HStack {
                        Text(password)
                        Spacer()
                        Button(action: {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = password
                        }, label: {
                            Image(systemName: "doc.on.doc")
                        })
                    }
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(RoundedBorder(borderColor: color))
                }

               
                
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .padding(.top, 60)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .overlay (alignment: .topTrailing, content: {
                Button(action: {
                    withAnimation {
                        showSyncInfoView = false
                    }
                }, label: {
                    Image(systemName: "xmark")
                        .padding(.all, 20)
                        .fontWeight(.bold)
                })
            })
            .padding(.horizontal, 30)
            .foregroundStyle(color)
        }

        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    @StateObject var viewManager = ViewManager()
    @StateObject var themeManager = ThemeManager()
    @StateObject var userManager = UserManager()

    @State var showNameChangeView: Bool = true
    return SyncInfoView(color: .red, password: "some", showSyncInfoView: $showNameChangeView)
        .environmentObject(viewManager)
        .environmentObject(userManager)
        .environmentObject(themeManager)

}
