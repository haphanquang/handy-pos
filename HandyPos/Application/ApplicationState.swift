//
//  ApplicationState.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/27.
//

import Foundation

struct ApplicationState {
    var userData = UserData()
    var routing = ViewRouter()
    var system = System()
    var permissions = Permissions()
    var repositories = Repositories()
}

extension ApplicationState {
    struct UserData: Equatable {
        var todayOrders = [Order]()
        var orderSession = Session()
        var activeMenu = Menu()
        var currentStore = Store()
        var settings = UserDefaults.standard.settings.toSettings {
            didSet {
                guard oldValue != settings else { return }
                UserDefaults.standard.settings = settings.rawValue
                UserDefaults.standard.synchronize()
            }
        }
        
        mutating func reset() {
            self.orderSession = Session()
            self.todayOrders = []
            if let menu = Menu.fixtures().first {
                self.activeMenu = menu
            }
        }
    }
}

extension ApplicationState {
    struct ViewRouter: Equatable { }
}

extension ApplicationState {
    struct System: Equatable { }
}

extension ApplicationState {
    struct Permissions: Equatable { }
}

extension ApplicationState {
    struct Repositories: Equatable {
        var localRepository = RealmRepository()
    }
}
