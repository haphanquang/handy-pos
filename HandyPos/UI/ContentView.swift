//
//  ContentView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/12.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    init(appState: AppState) {
        viewModel = ContentViewModel(appState: appState)
    }
    
    var body: some View {
        HomeView(viewModel: viewModel.homeViewModel)
            .environment(\.locale, viewModel.language)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appState: ApplicationEnvironment.bootstrap().appState)
    }
}

class ContentViewModel: ObservableObject {
    @Published var language: Locale
    
    let appState: AppState
    let homeViewModel: HomeViewModel
    private var cancelBag = CancelBag()
    
    init(appState: AppState) {
        self.appState = appState
        language = Locale(
            identifier: appState.value.userData.settings.userSelectedLanguage ?? Language.vietnam.rawValue
        )
        homeViewModel = HomeViewModel(appState: appState)
        transform()
    }
    
    private func transform() {
        appState.publisher(for: \.userData.settings.userSelectedLanguage)
            .replaceNil(with: Language.vietnam.rawValue)
            .map { Locale(identifier: $0) }
            .assign(to: &$language)
    }
}
