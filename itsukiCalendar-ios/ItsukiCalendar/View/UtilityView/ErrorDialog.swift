//
//  Error.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/28.
//


import SwiftUI

struct ErrorDialogParameter {
    var errorMessage: String? = nil
    var performActionAfterClosed: () -> Void = {}
}


struct ErrorDialog: View {
    var color: Color
    var error: ErrorDialogParameter?
    @Binding var isError: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.7))
                .ignoresSafeArea()
            
            ZStack {
                Image("calendarFrame", bundle: nil)
                    .resizable()
                    .aspectRatio(16/15, contentMode: .fit)


                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 70))
                        .padding(.top, 30)
                    
                    if (error?.errorMessage?.isEmpty == false) {
                        Text(error!.errorMessage!)
                            .font(.system(size: 16))
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                }
            }
            .padding(.horizontal, 35)
            .padding(.bottom, 20)
            .padding(.top, 40)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .overlay (alignment: .topTrailing, content: {
                Button(action: {
                    withAnimation {
                        isError = false
                        error?.performActionAfterClosed()
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
    @State var isError: Bool = false
    let error = ErrorDialogParameter()
    return ErrorDialog(color: Color.red, error: error, isError: $isError)
}
