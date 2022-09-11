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
import CryptoKit
import SwiftUI

struct Utils {
    static func hmac(message: Data, key: Data) -> Data? {
        let key = SymmetricKey(data: key)
        let signature = HMAC<SHA512>.authenticationCode(for: message, using: key)
        return Data(signature)
    }
}

extension Double {
    var money: String? {
        guard self >= 0 else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.init(identifier: "vi_VN")
        return formatter.string(from: self as NSNumber)
    }
    
    var shortedMoney: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        guard self <= 999_999_999 else {
            return formatter.string(from: NSNumber(value: self / 1e9))! + "B"
        }
        
        guard self <= 999_999 else {
            return formatter.string(from: NSNumber(value: self / 1e6))! + "M"
        }
        
        guard self <= 999 else {
            return formatter.string(from: NSNumber(value: self / 1e3))! + "K"
        }
        
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension Date {
    func timeAgoDisplay(locale: Locale? = Locale.init(identifier: "vi_VN")) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = locale
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: Mini Apps
extension String {
    func applyBOM() -> Self {
        let bom: String.Element = "\u{FEFF}"
        let zws: String.Element = "\u{200B}"
        var result = ""
        forEach {
            if $0 != zws {
                result.append("\($0)\(bom)")
            } else {
                if result.last == bom {
                    result.removeLast()
                }
            }
        }
        if result.last == bom {
            result.removeLast()
        }
        return result
    }
}

extension String {
    func splitEnv() -> [String] {
        return components(separatedBy: "/﻿/﻿")
    }
    
    func componentsFor(every count: Int) -> [String] {
        var result = [String]()
        var copy = self
        while copy.count > count {
            let component = String(copy.prefix(count))
            copy.removeFirst(count)
            result.append(component)
        }
        result.append(copy)
        return result
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Data {
    // slower than using hard-coded table like ios shopper
    func crc16CCITTFalse() -> Int {
        var initial = 0xFFFF
        let poly = 0x1021
        
        for aByte in self {
            initial ^= Int(aByte) << 8
            for _ in 0..<8 {
                if (initial & 0x8000) > 0 {
                    initial = (initial << 1) ^ poly
                } else {
                    initial = initial << 1
                }
            }
        }
        return initial & 0xFFFF
    }
}

extension Int {
    var hexString: String {
        return String(format: "%04X", self)
    }
}

extension ProcessInfo {
    var isRunningTests: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    var rgb: Int? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        if UIColor(self).getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            return nil
        }
    }
}

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { lower, higher in
            return lower[keyPath: keyPath] < higher[keyPath: keyPath]
        }
    }
}
