//
//  Realm+Store.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/04/16.
//

import Foundation
import RealmSwift

final class RealmStore: Object, DomainConvertible {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var logo: String?
    @Persisted var address1: String?
    @Persisted var address2: String?
    @Persisted var phoneNumber: String?
    @Persisted var zipCode: String?
    
    func toDomainObject() -> Store {
        Store(
            id: id,
            name: name,
            logo: logo,
            address1: address1,
            address2: address2,
            phoneNumber: phoneNumber,
            zipCode: zipCode
        )
    }
    
    static func fromDomainObject(_ model: Store) -> RealmStore {
        let obj = RealmStore()
        obj.id = model.id
        obj.name = model.name
        obj.logo = model.logo
        obj.address1 = model.address1
        obj.address2 = model.address2
        obj.phoneNumber = model.phoneNumber
        obj.zipCode = model.zipCode
        return obj
    }
}
