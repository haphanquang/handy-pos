//
//  Settings.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/01/02.
//

import Foundation

struct Settings: Codable, Equatable {
    var version: UInt64?
    var defaultMenuTab: InputTab = .menu
    var userSelectedLanguage: String?
    
    static let `default` = Settings(version: 1)
    static let currentVersion: UInt64 = 1
}

extension Settings {
    public init(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(Settings.self, from: data)
        else {
            self = Settings.default
            return
        }
        self = result
    }

    public var rawValue: String {
        guard
            let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return result
    }
}

extension String {
    var toSettings: Settings {
        return Settings(rawValue: self)
    }
}

extension UserDefaults {
    @objc
    var settings: String {
        get {
            return Self.standard.string(forKey: "pos.user.settings") ?? Settings.default.rawValue
        } set {
            Self.standard.setValue(newValue, forKey: "pos.user.settings")
        }
    }
    
    @objc
    var orders: String? {
        get {
            return Self.standard.string(forKey: "pos.orders")
        } set {
            Self.standard.setValue(newValue, forKey: "pos.orders")
        }
    }
    
    @objc
    var menus: String? {
        get {
            return Self.standard.string(forKey: "pos.menus")
        } set {
            Self.standard.setValue(newValue, forKey: "pos.menus")
        }
    }
    
    @objc
    var stores: String? {
        get {
            return Self.standard.string(forKey: "pos.stores")
        } set {
            Self.standard.setValue(newValue, forKey: "pos.stores")
        }
    }
}
