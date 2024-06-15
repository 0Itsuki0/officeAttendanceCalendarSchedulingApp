//
//  ExchangeFinishView.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/04.
//

import SwiftUI

struct ExchangeFinishView: View {
    @EnvironmentObject var viewManager: ViewManager

    var exchangeAnimation: Namespace.ID
    var color: Color
    
    @Binding var promotionExchanged: PromotionType?
    @Binding var promotionCode: String?
    
    @Environment(\.displayScale) private var displayScale

    @StateObject private var imageManager = ImageManager()
    @State private var shareCardView: ShareCardView? = nil
    @State private var imageShareTransferable: ImageManager.ImageShareTransferable? = nil
    @State private var saveFinished: Bool = false


    var body: some View {
        if let type = promotionExchanged, let code = promotionCode {

            VStack(spacing: 40){
                
                Spacer()
                    .frame(height: 10)
                
                Image("\(type)", bundle: nil)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .matchedGeometryEffect(id: "\(type)ExchangeImage", in: exchangeAnimation)
                    .overlay(alignment: .topTrailing, content: {
                        HStack(spacing:2) {
                            Image(systemName: "yensign")
                                .font(.system(size: 12))
                            Text("\(Constants.PromotionConstants.promotionValue)")
                        }
                        .offset(x: 50, y: -10)
                    })
                
                Text(type.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.title3)
                    .matchedGeometryEffect(id: "\(type)ExchangeTitle", in: exchangeAnimation)

                HStack {

                    if let shareCardView = shareCardView {
                        Spacer()
                        Button(action: {
                            imageManager.saveView(shareCardView, scale: displayScale)

                        }, label: {
                            Image(systemName: saveFinished ? "checkmark" : "arrow.down.to.line")
                        })
                        .disabled(saveFinished)
                        Spacer()

                    }

                    
                    if let imageShareTransferable = imageShareTransferable {
                        Divider()
                            .background(color)
                            .frame(height: 30)

                        Spacer()
                        ShareLink(
                            item: imageShareTransferable,
                            preview: SharePreview(
                                imageShareTransferable.caption,
                                image: imageShareTransferable.image)) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                        Spacer()

                    }

                    

                }
                .font(.system(size: 24))
                .frame(maxWidth: .infinity, alignment: .center)

                                
                HStack(spacing: 20) {
                   Image(systemName: "barcode.viewfinder")
                       .font(.system(size: 24))
                    
                    HStack {
                        Text(code)
                        Spacer()
                        Button(action: {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = code
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
            .overlay(content: {
                Button(action: {
                    withAnimation {
                        promotionCode = nil
                        promotionExchanged = nil
                    }
                }, label: {
                    Image(systemName: "xmark")
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            })
            .onAppear {
                self.shareCardView = ShareCardView(color: color, promotionType: type, promotionCode: code)
                imageShareTransferable = imageManager.getTransferable(shareCardView, scale: displayScale, caption: type.title)

            }
            .onChange(of: imageManager.imageSaved) {
                saveFinished = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    saveFinished = false
                }
            }
            .onChange(of: imageManager.errorMessage) {
                guard let message = imageManager.errorMessage else {return}
                viewManager.showError(message)
                imageManager.errorMessage = nil
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 35)
            .padding(.vertical, 40)
            .modifier(NeumorphismRectangleBackground(color: color))
            .matchedGeometryEffect(id: "\(type)ExchangeFrame", in: exchangeAnimation)
            .padding(.horizontal, 20)
            .padding(.vertical, 120)
        }
    }
}

#Preview {
    @StateObject var viewManager = ViewManager()
    let themeManager = ThemeManager()
    let userManager = UserManager()

    @Namespace var animation
    @State var promotionExchanged: PromotionType? = .amazon
    @State var promotionCode: String? = "someCode"


    return ExchangeFinishView(exchangeAnimation: animation, color: .red, promotionExchanged: $promotionExchanged, promotionCode: $promotionCode)
        .environmentObject(viewManager)
        .environmentObject(themeManager)
        .environmentObject(userManager)

}
