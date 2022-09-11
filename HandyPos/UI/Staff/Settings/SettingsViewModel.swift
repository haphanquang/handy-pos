//
//  SettingsViewModel.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/04/16.
//

import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    let appState: AppState
    let menuSettingsViewModel: MenuSettingsViewModel
    let storeSettingsViewModel: StoreSettingsViewModel
    
    private let cancelBag = CancelBag()
    
    @Published var isSaving: Bool = false
    @Published var savingErrorMessage: String?
    @Published var selectedLanguage: Language = .english
    private(set) var allLanguages = Language.allCases
    
    init(appState: AppState) {
        self.appState = appState
        self.menuSettingsViewModel = MenuSettingsViewModel(appState: appState)
        self.storeSettingsViewModel = StoreSettingsViewModel(appState: appState)
        transform()
    }
    
    func transform() {
        appState
            .publisher(for: \.userData.settings.userSelectedLanguage)
            .compactMap {
                if
                    let language = $0,
                    let lang = Language(rawValue: language)
                {
                    return lang
                }
                return nil
            }
            .assign(to: &$selectedLanguage)
        
        $selectedLanguage
            .removeDuplicates()
            .sink { [appState] val in
                appState.bulkUpdate {
                    $0.userData.settings.userSelectedLanguage = val.rawValue
                }
            }.store(in: cancelBag)

        $selectedLanguage
            .dropFirst()
            .removeDuplicates()
            .sink { _ in
                DeviceFeedbacks.playSelected()
            }.store(in: cancelBag)
    }
    
    func resetDatabase() {
        appState.bulkUpdate {
            $0.userData.reset()
            $0.repositories.localRepository.reset()
        }
    }
    
    func sync() {
        // TODO: Cloud saving
    }
    
}

enum Language: String, CaseIterable {
    case english = "en"
    case vietnam = "vi"
    
    var title: String {
        switch self {
        case .english: return "🇺🇸 Eng"
        case .vietnam: return "🇻🇳 Việt"
        }
    }
    
    var locale: Locale {
        return Locale(identifier: self.rawValue)
    }
}
