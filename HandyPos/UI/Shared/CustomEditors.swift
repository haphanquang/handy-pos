/*
* Copyright (c) Rakuten Payment, Inc. All Rights Reserved.
*
* This program is the information asset which are handled
* as "Strictly Confidential".
* Permission of use is only admitted in Rakuten Payment, Inc.
* If you don't have permission, MUST not be published,
* broadcast, rewritten for broadcast or publication
* or redistributed directly or indirectly in any medium.
*/

import Foundation
import SwiftUI

struct HeaderTextField: View {
    let title: String
    @Binding var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title)).font(.caption)
                    .foregroundColor(.secondary)
                TextField(LocalizedStringKey("nhập ..."), text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }.padding(.top, 6)
        }
    }
}

struct HeaderTextEditor: View {
    let title: String
    @Binding var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title))
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextEditor(text: $text)
                    .font(.caption)
            }.padding(.top, 4)
        }
    }
}

struct EnableClearButton: ViewModifier {
    @Binding var text: String
    func body(content: Content) -> some View {
        HStack {
            content
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }, label: {
                    Image(systemName: "delete.left").foregroundColor(Color(UIColor.opaqueSeparator))
                })
            }
        }
    }
}

extension HeaderTextField {
    func showsClearWhileEditing(_ text: Binding<String>) -> some View {
        self.modifier(EnableClearButton(text: text))
    }
}
