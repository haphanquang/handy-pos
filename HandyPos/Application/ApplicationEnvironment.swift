//
//  ApplicationEnvironment.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/27.
//

import Foundation
import Firebase

typealias AppState = StoreValue<ApplicationState>

struct ApplicationEnvironment {
    let appState: AppState
    let eventsHandler: SystemEventsHandler
    private var cancelBag = CancelBag()
    
    init(appState: AppState, eventsHandler: SystemEventsHandler) {
        FirebaseApp.configure()
        self.appState = appState
        self.eventsHandler = eventsHandler
        self.doMigration()
        self.prepareAppState()
    }
    
    func prepareAppState() {
        self.appState.value.repositories
            .localRepository
            .fetchTodayOrders()
            .replaceError(with: [])
            .sink { [appState] orders in
                appState.bulkUpdate {
                    $0.userData.todayOrders = orders.sorted(by: { $0.inTime > $1.inTime })
                }
            }.store(in: cancelBag)
        
        self.appState.value.repositories
            .localRepository
            .fetchActiveMenu()
            .replaceError(with: Menu.fixtures().first!)
            .sink { [appState] menu in
                appState.bulkUpdate { $0.userData.activeMenu = menu }
            }.store(in: cancelBag)
        
        self.appState.value.repositories
            .localRepository
            .fetchCurrentStore()
            .replaceError(with: Store())
            .sink { [appState] store in
                appState.bulkUpdate { $0.userData.currentStore = store }
            }.store(in: cancelBag)
    }
    
    func doMigration() {
        var currentSettings = UserDefaults.standard.settings.toSettings
        let currentVersion = currentSettings.version ?? 0
        
        if currentVersion < 1 { }
        if currentVersion < 2 { }
        
        // Special language migration for all versions
        if currentSettings.userSelectedLanguage == nil {
            currentSettings.userSelectedLanguage = "vi"
        }
        
        currentSettings.version = Settings.currentVersion
        UserDefaults.standard.settings = currentSettings.rawValue
    }
}

extension ApplicationEnvironment {
    static func bootstrap() -> ApplicationEnvironment {
        let appState = StoreValue(ApplicationState())
        let deepLinksHandler = RealDeepLinksHandler(appState: appState)
//        let bluetoothHandler = BluetoothHandler(appState: appState)
        let systemHandlers = RealSystemEventsHandler(
            appState: appState,
            deepLinksHandler: deepLinksHandler
//            bluetoothHandler: bluetoothHandler
        )
        return ApplicationEnvironment(appState: appState, eventsHandler: systemHandlers)
    }
}
