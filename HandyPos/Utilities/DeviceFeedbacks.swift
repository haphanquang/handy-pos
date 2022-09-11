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
import UIKit

struct DeviceFeedbacks {
    private static var generator: UIImpactFeedbackGenerator?
    static func prepare() {
        if isFeedbackSupport() {
            generator = UIImpactFeedbackGenerator(style: .light)
            generator?.prepare()
        }
    }
    static func playSelected() {
        generator?.impactOccurred()
    }
    static func playPaymentSuccessfully() {
        if isFeedbackSupport() {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    static func isFeedbackSupport() -> Bool {
        if let value = UIDevice.current.value(forKey: "_feedbackSupportLevel") {
            let result = value as? Int
            return result == 2 ? true : false
        }
        return false
    }
}
