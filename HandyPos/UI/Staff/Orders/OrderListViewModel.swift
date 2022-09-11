//
//  OrderListViewModel.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/27.
//

import Foundation
import Combine

class OrderListViewModel: ObservableObject {
    @Published var orderFilter: FilterOptions = .all
    @Published var orders: [Order] = []
    @Published var editingOrder: Order?
    @Published var selectedDate = Date()
    @Published var dateTitle = "Hôm nay"
    
    let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func transform() {
        $selectedDate.map { [appState] date -> AnyPublisher<[Order], Never> in
            if Calendar.current.isDateInToday(date) {
                return appState
                    .publisher(for: \.userData.todayOrders)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            } else {
                return appState.value
                    .repositories
                    .localRepository
                    .fetchOrders(on: date)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
        }
        .switchToLatest()
        .combineLatest($orderFilter) { orders, filter in
            return filter.apply(on: orders)
        }
        .assign(to: &$orders)
        
        $selectedDate.map { [appState] date -> String in
            let dateFormater = DateFormatter()
            dateFormater.dateStyle = .medium
            dateFormater.locale = Locale(
                identifier: appState.value.userData.settings.userSelectedLanguage ?? Language.vietnam.rawValue
            )
            if Calendar.current.isDateInToday(date) {
                return "Hôm nay"
            } else {
                return dateFormater.string(from: date)
            }
        }.assign(to: &$dateTitle)
    }
}
