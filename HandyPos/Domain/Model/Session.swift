//
//  Session.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/28.
//

import Foundation
import SwiftUI
import OrderedCollections

struct SessionItem: Identifiable, Hashable {
    var id: String
    var code: String
    var name: String
    var price: Price
    var cost: Price?
    var color: Color? = Color.gray.opacity(0.5)
    var tag: String
    
    init(id: String, code: String, name: String, price: Price, cost: Price?, color: Color? = nil) {
        self.id = id
        self.code = code
        self.name = name
        self.price = price
        self.cost = cost
        self.color = color
        self.tag = "\(code), \(name.folded), \(name)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Session: Equatable, Identifiable {
    var id: Date { createdDate }
    var createdDate = Date()
    
    private(set) var selected = OrderedDictionary<SessionItem, SessionSelectedInfo>()
    
    init() { }
    init(order: Order) {
        self.createdDate = order.inTime
        
        for (dish, amount) in order.mergedItems {
            let item = SessionItem(
                id: dish.id,
                code: dish.code,
                name: dish.name,
                price: dish.price,
                cost: dish.estimatedCost,
                color: dish.color
            )
            selected[item] = SessionSelectedInfo(quantity: amount, extra: nil)
        }
    }
    
    mutating func merge(with session: Session) {
        for (key, value) in session.selected {
            if let exist = selected[key] {
                selected[key] = SessionSelectedInfo(quantity: exist.quantity + value.quantity, extra: nil)
            } else {
                selected[key] = value
            }
        }
    }
    
    var quantity: Int {
        return selected.values.map { $0.quantity }.reduce(0, +)
    }
    
    var totalAmount: Price {
        var amount = Price(amount: 0)
        for (key, value) in selected {
            amount = amount.add(to: key.price.multiply(by: value.quantity))
        }
        return amount
    }
    
    subscript(item: SessionItem) -> SessionSelectedInfo? {
        get {
            // provide empty item when access
            selected[item] ?? SessionSelectedInfo(quantity: 0, extra: nil)
        }
        set(newValue) {
            guard
                let newValue = newValue,
                newValue.quantity > 0
            else {
                selected[item] = nil
                return
            }
            selected[item] = newValue
        }
    }
}

public struct SessionSelectedInfo: Equatable {
    var quantity: Int
    var extra: String?
}

extension String {
    // Reference https://stackoverflow.com/questions/16836975/ios-cfstringtransform-and-%C4%90
    var folded: String {
        return self.folding(options: .diacriticInsensitive, locale: nil)
                .replacingOccurrences(of: "đ", with: "d")
                .replacingOccurrences(of: "Đ", with: "D")
    }
}
