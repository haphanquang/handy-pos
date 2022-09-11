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
import UIKit

protocol SystemEventsHandler {
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>)
    func handle(url: URL)
}

struct RealSystemEventsHandler: SystemEventsHandler {
    let appState: StoreValue<ApplicationState>
    let deepLinksHandler: DeepLinksHandler
//    let bluetoothHandler: BluetoothHandler
    
    private var cancelBag = CancelBag()
    
    init(
        appState: StoreValue<ApplicationState>,
        deepLinksHandler: DeepLinksHandler
//        bluetoothHandler: BluetoothHandler
    ) {
        self.appState = appState
        self.deepLinksHandler = deepLinksHandler
//        self.bluetoothHandler = bluetoothHandler
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }
    
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
        guard let url = urlContexts.first?.url else { return }
        handle(url: url)
    }
    
    func handle(url: URL) {
        deepLinksHandler.open(deepLink: DeepLink(url: url))
    }
}
