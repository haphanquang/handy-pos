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
import Combine

class WebBrowserViewModel: ObservableObject {
    @Published var title: String = "Browser"
    @Published private(set) var webViewModel: WebViewViewModel
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var currentURL: URL?
    
    init(url: URL) {
        self.webViewModel = WebViewViewModel(url: url)
        self.currentURL = url

        webViewModel
            .$isLoading
            .compactMap { $0 }
            .assign(to: &$isLoading)
        
        webViewModel
            .$recentURL
            .assign(to: &$currentURL)
    }
    
    convenience init(url: URL, title: String) {
        self.init(url: url)
        self.title = title
    }
    
    func reload() {
        webViewModel.reload()
    }
}
