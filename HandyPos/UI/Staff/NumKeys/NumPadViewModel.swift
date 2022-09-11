//
//  NumPadViewModel.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/05/26.
//

import Foundation
import SwiftUI
import Combine

class NumPadViewModel: ObservableObject {
    @Published var moneyText: String = 0.money!
    @Published var note: String = ""
    @Published var actionButtonTitle: LocalizedStringKey = LocalizedStringKey("")
    
    @Published var alertPresented: Bool = false
    @Published var reviewingOrder: Order?
    
    private(set) var itemList = CurrentValueSubject<[OrderItem]?, Never>(nil)
    private(set) var number = CurrentValueSubject<Double, Never>(0)
    
    var currentNumber: Double = 0 {
        didSet {
            number.send(currentNumber)
        }
    }
    private(set) var appState: AppState
    private var cancelBag = CancelBag()
    
    init(appState: AppState) {
        self.appState = appState
        self.transform()
    }
    
    private func transform() {
        itemList.combineLatest(number) { items, number -> LocalizedStringKey in
            if let list = items, !list.isEmpty {
                return LocalizedStringKey("Xem đơn \(list.count) món")
            } else {
                return LocalizedStringKey("Chốt \(number.money!)")
            }
        }.assign(to: &$actionButtonTitle)
        
        number.compactMap { $0.money }.assign(to: &$moneyText)
    }
    
    func tap(_ button: String) {
        switch button {
        case "C": currentNumber = 0
        case "000":
            currentNumber *= 1000
        default:
            currentNumber = currentNumber * 10 + Double(button)!
        }
        currentNumber = min(currentNumber, 999_999_999)
    }
    
    func onTapAppendItem() {
        guard currentNumber > 0 else { return }
        var list = itemList.value ?? []
        list.append(makeOrderItem())
        itemList.send(list)
        currentNumber = 0
    }
    
    func onTapConfirm() {
        guard let list = itemList.value, list.count > 0 else {
            alertPresented = currentNumber > 0
            return
        }
        reviewingOrder = makeOrder()
    }
    
    func removeItem(_ id: String) {
        var list = itemList.value ?? []
        list.removeAll { $0.dishes.keys.first?.id == id }
        itemList.send(list)
    }
    
    func finishReviewingOrder() {
        itemList.send(nil)
    }
    
    func clearItems() {
        itemList.send(nil)
    }

    func sendNewOrder() {
        guard currentNumber > 0 else { return }
        let order = makeOrder()
        
        self.appState.bulkUpdate { appState in
            appState.userData.todayOrders.insert(order, at: 0)
            appState.userData.orderSession = Session()
        }
        
        self.appState.value.repositories
            .localRepository
            .insertOrder(order)
            .sink { _ in } receiveValue: { [weak self] _ in
                DeviceFeedbacks.playPaymentSuccessfully()
                self?.note = ""
            }
            .store(in: cancelBag)
        
        currentNumber = .zero
    }
}

extension NumPadViewModel {
    private func makeOrderItem() -> OrderItem {
        let orderDate = Date()
        let dish = Dish(
            id: UUID().uuidString,
            name: "Tuỳ chọn giá",
            code: Dish.customPriceCode,
            price: Price(amount: currentNumber),
            estimatedCost: nil,
            description: "Giá tuỳ chọn",
            cookingTime: nil,
            color: nil,
            customization: nil
        )
        let allItems = OrderItem(
            id: UUID().uuidString,
            dishes: [dish: 1],
            orderTime: orderDate,
            status: .serving
        )
        return allItems
    }
    
    private func makeOrder() -> Order {
        if let multipleItems = itemList.value, !multipleItems.isEmpty {
            return Order(
                id: UUID().uuidString,
                inTime: multipleItems.first?.orderTime ?? Date(),
                totalCustomer: 1,
                quantity: 1,
                note: !note.isEmpty ? note : nil,
                outTime: multipleItems.last?.orderTime,
                sender: nil,
                maleCount: nil,
                femaleCount: nil,
                children: nil,
                orderItems: multipleItems,
                status: .finished
            )
        } else {
            let singleItem = makeOrderItem()
            return Order(
                id: UUID().uuidString,
                inTime: singleItem.orderTime,
                totalCustomer: 1,
                quantity: 1,
                note: !note.isEmpty ? note : nil,
                outTime: singleItem.orderTime,
                sender: nil,
                maleCount: nil,
                femaleCount: nil,
                children: nil,
                orderItems: [singleItem],
                status: .finished
            )
        }
    }
}
