//
//  ClearableTextField.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/06/15.
//

import SwiftUI

struct ClearableTextField: View {

    var title: String
    @Binding var text: String
    var isSecure: Bool = false

    init(_ title: String, text: Binding<String>, isSecure: Bool = false) {
        self.title = title
        _text = text
        self.isSecure = isSecure
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            if isSecure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
            }
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary.opacity(0.8))
                })
            }
        }
    }
}


#Preview {
    @State var text = ""
    return ClearableTextField("test", text: $text)
}
