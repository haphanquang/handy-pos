//
//  OrderConfirmationViewModel.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/28.
//

import Foundation
import OrderedCollections

class OrderConfirmationViewModel: ObservableObject {
    @Published var sessionInfo: Session
    @Published var subtotal: String
    @Published var total: String
    @Published var status: OrderStatus
    @Published var note: String = ""
    @Published var errorMessage: String?
    @Published var isUpdatingOrder = false
    @Published var orderStatuses: [OrderStatus]
    
    private(set) var appState: AppState
    private var cancelBag = CancelBag()
    private var order: Order?
    
    init(session: Session, appState: AppState, isFastOrder: Bool = true) {
        self.sessionInfo = session
        self.subtotal = session.totalAmount.formatted
        self.total = session.totalAmount.formatted
        self.appState = appState
        self.status = isFastOrder ? .finished : .new
        if isFastOrder {
            self.orderStatuses = [.finished, .new, .preparing, .serving, .delivering, .cancelled]
        } else {
            self.orderStatuses = OrderStatus.allCases
        }
        self.transform()
    }
    
    init(order: Order, appState: AppState) {
        let session = Session(order: order)
        self.sessionInfo = session
        self.subtotal = session.totalAmount.formatted
        self.total = session.totalAmount.formatted
        self.status = order.status
        self.order = order
        self.note = order.note ?? ""
        self.appState = appState
        self.isUpdatingOrder = true
        self.orderStatuses = OrderStatus.allCases
        self.transform()
    }
    
    func confirmOrder() -> Bool {
        guard sessionInfo.quantity > 0 else {
            errorMessage = "Đơn hàng của bạn không có món nào. Xin hãy kiểm tra lại"
            return false
        }
        
        if let order = order, isUpdatingOrder {
            update(order)
        } else {
            saveNewOrder()
        }
        return true
    }
    
    func deleteItem(offsets: IndexSet) {
        let keys = sessionInfo.selected.keys
        for index in offsets {
            sessionInfo[keys[index]] = nil
        }
    }
    
    func deleteOrder() {
        guard let order = order else { return }
        
        self.appState.bulkUpdate { appState in
            appState.userData.todayOrders.removeAll(where: { $0.id == order.id })
        }
        
        self.appState.value.repositories
            .localRepository
            .deleteOrder(order)
            .sink(receiveCompletion: { [weak self] completion in
                if completion.error != nil { self?.errorMessage = "Không thể xoá lúc này" }
            }, receiveValue: { _ in })
            .store(in: cancelBag)
    }
    
    func merge(_ session: Session) {
        sessionInfo.merge(with: session)
    }
    
    private func transform() {
        $errorMessage
            .reset(after: 2, on: RunLoop.main)
            .removeDuplicates()
            .assign(to: &$errorMessage)
    }
}

extension OrderConfirmationViewModel {
    private func makeOrder(_ old: Order? = nil) -> Order {
        var dishes = [Dish: Int]()
        for (item, itemInfo) in sessionInfo.selected {
            let dish = Dish(
                id: item.id,
                name: item.name,
                code: item.code,
                price: item.price,
                estimatedCost: item.cost,
                description: item.name,
                cookingTime: nil,
                color: item.color,
                customization: nil)
            dishes[dish] = itemInfo.quantity
        }
        
        let allItems = OrderItem(
            id: UUID().uuidString,
            dishes: dishes,
            orderTime: sessionInfo.createdDate,
            status: .serving)
        
        let order = Order(
            id: old?.id ?? UUID().uuidString,
            inTime: old?.inTime ?? Date(),
            totalCustomer: old?.quantity ?? 1,
            quantity: sessionInfo.quantity,
            note: !note.isEmpty ? note : nil,
            outTime: old?.outTime,
            sender: old?.sender,
            maleCount: old?.maleCount,
            femaleCount: old?.femaleCount,
            children: old?.children,
            orderItems: [allItems],
            status: status
        )
        return order
    }
    
    private func saveNewOrder() {
        let order = makeOrder()
        self.appState.bulkUpdate { appState in
            appState.userData.todayOrders.insert(order, at: 0)
            appState.userData.orderSession = Session()
        }
        
        self.appState.value.repositories
            .localRepository
            .insertOrder(order)
            .sink { _ in } receiveValue: { _ in }
            .store(in: cancelBag)
    }
    
    private func update(_ order: Order) {
        let order = makeOrder(order)
        self.appState.bulkUpdate { appState in
            var orders = appState.userData.todayOrders
            if let index = orders.firstIndex(where: { $0.id == order.id }) {
                orders[index] = order
            }
            appState.userData.todayOrders = orders.sorted(by: { $0.inTime > $1.inTime })
        }
        
        self.appState.value.repositories
            .localRepository
            .updateOrder(order)
            .sink { _ in } receiveValue: { _ in }
            .store(in: cancelBag)
    }
}

extension OrderConfirmationViewModel {
    func prepareBill() -> Data {
        let store = appState.value.userData.currentStore
        let order = makeOrder()
        return PDFBuilder(store: store, order: order).makePDFData()
    }
}
