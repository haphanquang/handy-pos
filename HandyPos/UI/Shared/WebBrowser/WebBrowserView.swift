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

struct WebBrowserView: View {
    @ObservedObject var viewModel: WebBrowserViewModel
    
    internal let inspection = Inspection<Self>() // for unittest
    
    var body: some View {
        VStack {
            WebView(webView: viewModel.webViewModel.webview)
            if let url = viewModel.currentURL {
                Link(
                    "Open in Safari",
                    destination: url
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().stroke(Color.blue))
            }
            // swiftlint:disable:next line_length
            Text("Since this is Webview, PayChan can not change its request's proxy. Please enable Device's proxy instead.")
                .font(.caption)
                .italic()
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 4)
        }
        .padding(8)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isLoading {
                    ActivityIndicatorView()
                } else {
                    Button(action: viewModel.reload) {
                        Image(systemName: "arrow.clockwise.circle")
                    }
                }
            }
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}
