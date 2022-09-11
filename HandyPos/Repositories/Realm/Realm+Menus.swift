//
//  Realm+Menus.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/02/08.
//

import Foundation
import RealmSwift
import SwiftUI

final class RealmMenu: Object, DomainConvertible {
    @Persisted(primaryKey: true) var id: String
    @Persisted var createdAt: Date
    @Persisted var expires: Date?
    @Persisted var activeDate: Date
    @Persisted var pages = RealmSwift.List<RealmMenuPage>()
    
    func toDomainObject() -> Menu {
        Menu(
            id: id,
            createdAt: createdAt,
            activeDate: activeDate,
            expireAt: expires, pages: pages.map { $0.toDomainObject() }
        )
    }
    
    static func fromDomainObject(_ model: Menu) -> RealmMenu {
        let obj = RealmMenu()
        obj.id = model.id
        obj.createdAt = model.createdAt
        obj.expires = model.expireAt
        obj.activeDate = model.activeDate
        model.pages.forEach {
            obj.pages.append(.fromDomainObject($0))
        }
        return obj
    }
}

final class RealmMenuPage: Object, DomainConvertible {
    @Persisted(primaryKey: true) var id: String
    @Persisted var index: Int
    @Persisted var background: String?
    @Persisted var layout: RealmPageLayout?
    @Persisted var dishes = RealmSwift.List<RealmDish>()
    
    func toDomainObject() -> MenuPage {
        MenuPage(
            id: id,
            index: index,
            dishes: dishes.map { $0.toDomainObject() },
            background: background,
            layout: layout?.toDomainObject()
        )
    }
    
    static func fromDomainObject(_ model: MenuPage) -> RealmMenuPage {
        let obj = RealmMenuPage()
        obj.id = model.id
        obj.index = model.index
        obj.background = model.background
        if let layout = model.layout {
            obj.layout = .fromDomainObject(layout)
        }
        model.dishes.forEach {
            obj.dishes.append(.fromDomainObject($0))
        }
        return obj
    }
}

final class RealmPageLayout: Object, DomainConvertible {
    @Persisted(primaryKey: true) var id: String
    @Persisted var layoutItem = RealmSwift.List<RealmLayoutItem>()
    
    func toDomainObject() -> PageLayout {
        PageLayout(id: id, layoutItem: layoutItem.map { $0.toDomainObject() })
    }
    
    static func fromDomainObject(_ model: PageLayout) -> RealmPageLayout {
        let obj = RealmPageLayout()
        obj.id = model.id
        model.layoutItem.forEach {
            obj.layoutItem.append(.fromDomainObject($0))
        }
        return obj
    }
}

final class RealmLayoutItem: Object, DomainConvertible {
    @Persisted var frame: String
    @Persisted var dish: RealmDish?
    
    func toDomainObject() -> PageLayout.LayoutItem {
        PageLayout.LayoutItem(
            frame: frame,
            dish: dish?.toDomainObject() ?? .init(id: "", name: "", code: "", price: Price(amount: 0))
        )
    }
    
    static func fromDomainObject(_ model: PageLayout.LayoutItem) -> RealmLayoutItem {
        let obj = RealmLayoutItem()
        obj.frame = model.frame
        obj.dish = .fromDomainObject(model.dish)
        return obj
    }
}

final class RealmDish: Object, _MapKey, DomainConvertible {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var code: String
    @Persisted var price: RealmPrice?
    @Persisted var estimatedCost: RealmPrice?
    @Persisted var details: String?
    @Persisted var cookingTime: Double?
    @Persisted var color: Int?
    @Persisted var customization = RealmSwift.List<RealmDishCustomization>()
    
    var profit: RealmPrice? {
        if let cost = estimatedCost {
            return price?.minus(by: cost)
        }
        return nil
    }
    
    func toDomainObject() -> Dish {
        Dish(
            id: id,
            name: name,
            code: code,
            price: price?.toDomainObject() ?? Price(amount: 0),
            estimatedCost: estimatedCost?.toDomainObject(),
            description: details,
            cookingTime: cookingTime,
            color: Color(hex: UInt(color ?? 0xff)),
            customization: customization.map {
                $0.toDomainObject()
            }
        )
    }
    
    static func fromDomainObject(_ model: Dish) -> RealmDish {
        let obj = RealmDish()
        obj.id = model.id
        obj.name = model.name
        obj.code = model.code
        obj.price = .fromDomainObject(model.price)
        if let estimatedCost = model.estimatedCost {
            obj.estimatedCost = .fromDomainObject(estimatedCost)
        }
        obj.details = model.description
        obj.cookingTime = model.cookingTime
        obj.color = model.color?.rgb
        obj.customization = List()
        model.customization?.forEach {
            obj.customization.append(.fromDomainObject($0))
        }
        return obj
    }
}

final class RealmDishCustomization: Object, DomainConvertible {
    @Persisted(primaryKey: true) var id: String
    @Persisted var details: String
    @Persisted var additionalPrice: RealmPrice?
    
    func toDomainObject() -> DishCustomization {
        DishCustomization(
            id: id,
            description: details,
            additionalPrice: additionalPrice?.toDomainObject() ?? Price(amount: 0)
        )
    }
    
    static func fromDomainObject(_ model: DishCustomization) -> RealmDishCustomization {
        let obj = RealmDishCustomization()
        obj.id = model.id
        obj.details = model.description
        if let price = model.additionalPrice {
            obj.additionalPrice = RealmPrice.fromDomainObject(price)
        }
        return obj
    }
}

final class RealmPrice: Object, DomainConvertible {
    @Persisted var amount: Double
    @Persisted var locale: String
    
    convenience init(amount: Double, locale: String) {
        self.init()
        self.amount = amount
        self.locale = locale
    }
    
    var formatted: String {
        return amount.money ?? "0đ"
    }
    
    func multiply(by quantity: Int) -> RealmPrice {
        return RealmPrice(amount: amount * Double(quantity), locale: locale)
    }
    
    func add(to price: RealmPrice) -> RealmPrice {
        return RealmPrice(amount: amount + price.amount, locale: locale)
    }
    
    func minus(by price: RealmPrice) -> RealmPrice {
        return RealmPrice(amount: amount - price.amount, locale: locale)
    }
    
    func toDomainObject() -> Price {
        Price(amount: self.amount, locale: Locale(identifier: self.locale))
    }
    
    static func fromDomainObject(_ model: Price) -> Self {
        return Self(amount: model.amount, locale: model.locale.identifier)
    }
}
