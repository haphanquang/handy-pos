//
//  Dish.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/12.
//

import Foundation
import SwiftUI

struct Dish: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var code: String
    var price: Price
    var estimatedCost: Price?
    var description: String?
    var cookingTime: Double?
    var color: Color?
    var customization: [DishCustomization]?
    
    var profit: Price? {
        if let cost = estimatedCost {
            return price.minus(by: cost)
        }
        return nil
    }
    
    static let customPriceCode = "TCH"
}

struct DishCustomization: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    let description: String
    let additionalPrice: Price?
}

struct Price: Codable, Hashable, Equatable {
    var amount: Double
    var locale: Locale = Locale(identifier: "vi_VN")
    
    var formatted: String {
        return amount.money ?? "0đ"
    }
    
    func multiply(by quantity: Int) -> Price {
        return Price(amount: amount * Double(quantity), locale: locale)
    }
    
    func add(to price: Price) -> Price {
        return Price(amount: amount + price.amount, locale: locale)
    }
    
    func minus(by price: Price) -> Price {
        return Price(amount: amount - price.amount, locale: locale)
    }
}

extension Dish {
    // swiftlint:disable:next function_body_length
    static func fixtures() -> [Dish] {
        return [
            .init(
                name: "Cà phê sữa đá",
                code: "CF01",
                price: Price(amount: 25000),
                estimatedCost: Price(amount: 15000),
                description: nil,
                cookingTime: nil,
                color: .green,
                customization: nil),
            .init(
                name: "Cà phê đen đá",
                code: "CF02",
                price: Price(amount: 27000),
                estimatedCost: Price(amount: 12000),
                description: nil,
                cookingTime: nil,
                color: .blue,
                customization: nil),
            .init(
                name: "Bạc xỉu",
                code: "BX01",
                price: Price(amount: 30000),
                estimatedCost: Price(amount: 14000),
                description: nil,
                cookingTime: nil,
                color: .red,
                customization: nil),
            .init(
                name: "Bánh tráng trộn",
                code: "BT01",
                price: Price(amount: 15000),
                estimatedCost: Price(amount: 12000),
                description: nil,
                cookingTime: nil,
                color: .gray,
                customization: nil),
            .init(
                name: "Bánh bột lọc",
                code: "BB01",
                price: Price(amount: 30000),
                estimatedCost: Price(amount: 15000),
                description: nil,
                cookingTime: nil,
                color: .orange,
                customization: nil),
            .init(
                name: "Bánh mỳ ốp la",
                code: "BM01",
                price: Price(amount: 18000),
                estimatedCost: Price(amount: 12000),
                description: nil,
                cookingTime: nil,
                color: .brown,
                customization: nil),
            .init(
                name: "Bánh mỳ thịt nướng",
                code: "BM02",
                price: Price(amount: 20000),
                estimatedCost: Price(amount: 10000),
                description: nil,
                cookingTime: nil,
                color: .cyan,
                customization: nil),
            .init(
                name: "Bánh mỳ đầy đủ",
                code: "BM03",
                price: Price(amount: 25000),
                estimatedCost: Price(amount: 14000),
                description: nil,
                cookingTime: nil,
                color: .indigo,
                customization: nil),
            .init(
                name: "Bánh mỳ pate",
                code: "BM04",
                price: Price(amount: 25000),
                estimatedCost: Price(amount: 14000),
                description: nil,
                cookingTime: nil,
                color: .pink,
                customization: nil)
        ]
    }
}
