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

struct LoadingButton: View {
    let action: () -> Void
    let title: String
    
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(LocalizedStringKey(title))
                    .foregroundColor(.green)
                Spacer()
                if let msg = errorMessage {
                    Text(LocalizedStringKey(msg))
                        .font(.subheadline)
                        .foregroundColor(.init(red: 1, green: 0.3, blue: 0.3))
                }
                if isLoading {
                    ActivityIndicatorView()
                }
            }
        }.disabled(isLoading)
    }
}

struct ToggleButton: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        Button {
            isShowing.toggle()
        } label: {
            Image(systemName: isShowing ? "eye" : "eye.slash").frame(width: 35, height: 35)
        }
    }
}
