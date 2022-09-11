//
//  LocalDataRepository.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/31.
//

import Foundation
import Combine

protocol LocalDataRespository {
    func fetchCurrentStore() -> AnyPublisher<Store, Error>
    func updateStore(_ store: Store) -> AnyPublisher<Bool, Error>
    func fetchActiveMenu() -> AnyPublisher<Menu, Error>
    func updateMenu(_ menu: Menu) -> AnyPublisher<Bool, Error>
    func fetchTodayOrders() -> AnyPublisher<[Order], Error>
    func fetchOrders(on date: Date) -> AnyPublisher<[Order], Error>
    func insertOrder(_ order: Order) -> AnyPublisher<Bool, Error>
    func updateOrder(_ order: Order) -> AnyPublisher<Bool, Error>
    func deleteOrder(_ order: Order) -> AnyPublisher<Bool, Error>
    func fetchRecentOrders(start: Date, end: Date?) -> AnyPublisher<[BusinessDate: [Order]], Error>
}

enum LocalDataRepositoryError: Error {
    case unknown
    case emptyOrders
    case notFound
    case db
}
