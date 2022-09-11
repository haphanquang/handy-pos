//
//  Realm+Orders.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/02/08.
//

import Foundation
import RealmSwift

final class RealmOrder: Object, DomainConvertible {
    @Persisted(primaryKey: true) var id: String
    @Persisted var inTime: Date
    @Persisted var totalCustomer: Int?
    @Persisted var quantity: Int?
    @Persisted var note: String?
    
    @Persisted var outTime: Date?
    @Persisted var sender: RealmCustomer?
    
    @Persisted var maleCount: Int?
    @Persisted var femaleCount: Int?
    @Persisted var children: Int?
    
    @Persisted var orderItems = RealmSwift.List<RealmOrderItem>()
    @Persisted var status: Int = 0
    
    func toDomainObject() -> Order {
        Order(
            id: id,
            inTime: inTime,
            totalCustomer: totalCustomer,
            quantity: quantity,
            note: note,
            outTime: outTime,
            sender: sender?.toDomainObject(),
            maleCount: maleCount,
            femaleCount: femaleCount,
            children: children,
            orderItems: orderItems.map { $0.toDomainObject() },
            status: OrderStatus(rawValue: status) ?? .new
        )
    }
    
    static func fromDomainObject(_ model: Order) -> RealmOrder {
        let obj = RealmOrder()
        obj.id = model.id
        obj.inTime = model.inTime
        obj.totalCustomer = model.totalCustomer
        obj.quantity = model.quantity
        obj.outTime = model.outTime
        obj.note = model.note
        if let sender = model.sender {
            obj.sender = .fromDomainObject(sender)
        }
        obj.maleCount = model.maleCount
        obj.femaleCount = model.femaleCount
        obj.children = model.children
        obj.orderItems = List()
        model.orderItems?.forEach {
            obj.orderItems.append(.fromDomainObject($0))
        }
        obj.status = model.status.rawValue
        return obj
    }
}

final class RealmCustomer: Object, DomainConvertible {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String?
    @Persisted var gender: Int?
    
    func toDomainObject() -> Customer {
        Customer(id: id, name: name, gender: gender)
    }
    
    static func fromDomainObject(_ model: Customer) -> RealmCustomer {
        let obj = RealmCustomer()
        obj.id = model.id
        obj.name = model.name
        obj.gender = model.gender
        return obj
    }
}

final class RealmOrderItem: Object, DomainConvertible {
    @Persisted(primaryKey: true) var id: String
    @Persisted var dishes = RealmSwift.Map<String, Int>()
    @Persisted var orderTime: Date = Date()
    @Persisted var status: Int = 0
    
    func toDomainObject() -> OrderItem {
        var converted = [Dish: Int]()
        let realm = try? Realm()
        for dish in dishes {
            if let obj = realm?.object(ofType: RealmDish.self, forPrimaryKey: dish.key)?.toDomainObject() {
                converted[obj] = dish.value
            }
        }
        return OrderItem(
            id: id,
            dishes: converted,
            orderTime: orderTime,
            status: OrderItemStatus(rawValue: status) ?? .new
        )
    }
    
    static func fromDomainObject(_ model: OrderItem) -> RealmOrderItem {
        let obj = RealmOrderItem()
        obj.id = model.id
        obj.dishes = Map<String, Int>()
        for (dish, amount) in model.dishes {
            obj.dishes[dish.id] = amount
        }
        obj.orderTime = model.orderTime
        obj.status = model.status.rawValue
        return obj
    }
}
