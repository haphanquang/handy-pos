//
//  DomainConvertible.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/02/23.
//

import Foundation

protocol DomainConvertible {
    associatedtype DomainModel
    func toDomainObject() -> DomainModel
    static func fromDomainObject(_ model: DomainModel) -> Self
}
