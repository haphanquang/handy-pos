//
//  GoodsGridViewModel.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/28.
//

import Foundation
import Combine
import SwiftUI

enum GridMode: Equatable {
    case fastOrder
    case normalOrder
    case addToOrder(_ session: Session)
    
    static func == (lhs: GridMode, rhs: GridMode) -> Bool {
        switch (lhs, rhs) {
        case (.fastOrder, .fastOrder): return true
        case (.normalOrder, .normalOrder): return true
        case (.addToOrder, .addToOrder): return true
        default: return false
        }
    }
}

class GoodsGridViewModel: ObservableObject {
    @Published var title = LocalizedStringKey("Đơn hàng")
    @Published var items: [SessionItem] = []
    @Published var searchString: String = ""
    @Published var confirmingSession: Session?
    @Published var session: Session
    
    private var cancelBag = CancelBag()
    private let onCompleted: ((Session) -> Void)?
    
    let mode: GridMode
    let appState: AppState
    
    init(appState: AppState, mode: GridMode = .fastOrder, onCompleted: ((Session) -> Void)? = nil) {
        self.appState = appState
        self.mode = mode
        switch mode {
        case .fastOrder:
            self.session = appState.value.userData.orderSession
            self.title = LocalizedStringKey("Bán nhanh")
        case .normalOrder:
            self.session = Session()
            self.title = LocalizedStringKey("Tạo mới")
        case let .addToOrder(session):
            self.session = session
            self.title = LocalizedStringKey("Thêm món")
        }
        self.onCompleted = onCompleted
        self.transform()
    }
    
    private func transform() {
        if mode == .fastOrder {
            appState.publisher(for: \.userData.orderSession)
                .assign(to: &$session)
            
            $session.removeDuplicates()
                .sink { [appState] session in
                    appState.bulkUpdate { $0.userData.orderSession = session }
                }.store(in: cancelBag)
        }
        
        appState.publisher(for: \.userData.activeMenu.dishes)
            .compactMap {
                $0.map {
                    SessionItem(
                        id: $0.id,
                        code: $0.code,
                        name: $0.name,
                        price: $0.price,
                        cost: $0.estimatedCost,
                        color: $0.color
                    )
                }
            }.combineLatest($searchString) { allItems, keyword in
                if keyword.isEmpty {
                    return allItems
                }
                return allItems.filter { $0.tag.uppercased().contains(keyword.uppercased()) }
            }
            .eraseToAnyPublisher()
            .assign(to: &$items)
    }
    
    func resetSelection() {
        if mode == .fastOrder {
            appState[\.userData.orderSession] = Session()
        } else {
            session = Session()
        }
    }
    
    func confirmOrder() {
        confirmingSession = session
    }
    
    func completeOrder() {
        onCompleted?(session)
    }
}
