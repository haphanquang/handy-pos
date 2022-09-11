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

internal final class Inspection<V> {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()
    
    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}
