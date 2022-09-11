//
//  HandyPosApp.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/12.
//

import SwiftUI

@main
struct HandyPosApp: App {
    let environment = ApplicationEnvironment.bootstrap()
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: environment.appState)
        }
    }
}
