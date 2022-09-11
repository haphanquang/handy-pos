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

extension Int {
    var arrayOfDigits: [Int] {
        var copy = self
        var result = [Int]()
        while copy > 0 {
            result.append(copy % 10)
            copy /= 10
        }
        return result.reversed()
    }
}

extension String {
    var isValidCreditCardNumber: Bool {
        guard count == 16 else { return false }
        
        var sum = 0
        let digitStrings = self.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            guard let digit = Int(tuple.element) else {
                return false
            }
            
            let odd = tuple.offset % 2 == 1
            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
}
