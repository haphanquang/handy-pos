//
//  Order.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/12.
//

import Foundation
import SwiftUI
import OrderedCollections

enum OrderStatus: Int, Codable, CaseIterable {
    case new = 0
    case preparing
    case serving
    case finished
    case cancelled
    case delivering
    
    var description: LocalizedStringKey {
        switch self {
        case .new: return LocalizedStringKey("mới tạo")
        case .preparing: return LocalizedStringKey("đang làm")
        case .serving: return LocalizedStringKey("đang phục vụ")
        case .finished: return LocalizedStringKey("hoàn tất")
        case .cancelled: return LocalizedStringKey("đã huỷ")
        case .delivering: return LocalizedStringKey("đang giao")
        }
    }
    
    var color: Color {
        switch self {
        case .new: return .blue
        case .preparing: return .green
        case .serving: return .teal
        case .delivering: return .teal
        case .finished: return .orange
        case .cancelled: return .gray
        }
    }
}

struct Order: Codable, Identifiable, Equatable {
    let id: String
    var inTime: Date
    var totalCustomer: Int?
    var quantity: Int?
    var note: String?
    
    var outTime: Date?
    var sender: Customer?
    
    var maleCount: Int?
    var femaleCount: Int?
    var children: Int?
    
    var orderItems: [OrderItem]?
    var status: OrderStatus = .new
    
    var mergedItems: OrderedDictionary<Dish, Int> {
        guard let items = orderItems else { return OrderedDictionary() }
        var merged = OrderedDictionary<Dish, Int>()
        for item in items {
            merged.merge(item.dishes, uniquingKeysWith: { $0 + $1 })
        }
        return merged
    }
    
    var summary: String {
        return mergedItems
            .map { "\($1)-\($0.code) \($0.price.formatted)" }
            .joined(separator: ", ")
    }
    
    var totalPrice: Price {
        return mergedItems
            .map { $0.price.multiply(by: $1) }
            .reduce(Price(amount: 0)) { partialResult, next in
                return partialResult.add(to: next)
            }
    }
    
    var totalProfit: Price {
        return mergedItems
            .compactMap { dish, quantity -> Price? in
                if let profit = dish.profit {
                    return profit.multiply(by: quantity)
                }
                return nil
            }
            .reduce(Price(amount: 0)) { partialResult, next in
                return partialResult.add(to: next)
            }
    }
}

enum OrderItemStatus: Int, Codable {
    case new = 0
    case preparing
    case serving
    case cancelled
}

struct OrderItem: Codable, Identifiable, Equatable {
    let id: String
    var dishes: [Dish: Int]
    var orderTime: Date = Date()
    var status: OrderItemStatus = .new
}
