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

enum DeepLink: Equatable {
    case none
    init(url: URL) {
        self = DeepLink.none
    }
}

protocol DeepLinksHandler {
    func open(deepLink: DeepLink)
}

struct RealDeepLinksHandler: DeepLinksHandler {
    private let appState: StoreValue<ApplicationState>
    
    init(appState: StoreValue<ApplicationState>) {
        self.appState = appState
    }
    
    func open(deepLink: DeepLink) {
    }
}
