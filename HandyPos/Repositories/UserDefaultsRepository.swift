//
//  UserDefaultsRepository.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/02/08.
//

import Foundation
import Combine

struct UserDefaultsRepository: LocalDataRespository, Equatable {
    init() { }
    
    func fetchTodayOrders() -> AnyPublisher<[Order], Error> {
        let today = BusinessDate(start: Date().startOfDay())
        return loadAllOrders()
            .map { $0[today] }
            .replaceNil(with: [])
            .eraseToAnyPublisher()
    }
    
    func fetchOrders(on date: Date) -> AnyPublisher<[Order], Error> {
        let dateToFetch = BusinessDate(start: date.startOfDay())
        return loadAllOrders()
            .map { $0[dateToFetch] }
            .replaceNil(with: [])
            .eraseToAnyPublisher()
    }
    
    func fetchCurrentStore() -> AnyPublisher<Store, Error> {
        return Fail<Store, Error>(error: LocalDataRepositoryError.notFound)
            .eraseToAnyPublisher()
    }
    
    func updateStore(_ store: Store) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { signal in
            do {
                try Self.saveStores([store])
                signal(.success(true))
            } catch {
                signal(.failure(LocalDataRepositoryError.unknown))
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchActiveMenu() -> AnyPublisher<Menu, Error> {
        Future<Menu, Error> { signal in
            if let menu = Self.getAllMenus().sorted(by: \.activeDate).last {
                signal(.success(menu))
            }
            signal(.failure(LocalDataRepositoryError.notFound))
        }.eraseToAnyPublisher()
    }
    
    func insertOrder(_ order: Order) -> AnyPublisher<Bool, Error> {
        saveOrders([order])
    }
    
    func updateOrder(_ order: Order) -> AnyPublisher<Bool, Error> {
        saveOrders([order])
    }
    
    func updateMenu(_ menu: Menu) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { signal in
            do {
                try Self.saveMenus([menu])
                signal(.success(true))
            } catch {
                signal(.failure(LocalDataRepositoryError.unknown))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteOrder(_ order: Order) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { signal in
            do {
                var allOrders = UserDefaultsRepository.getAllOrders()
                let replaceDate = BusinessDate(start: order.inTime.startOfDay())

                guard
                    var newOrders = allOrders[replaceDate],
                    let index = newOrders.firstIndex(where: { $0.id == order.id })
                else {
                    signal(.failure(LocalDataRepositoryError.notFound))
                    return
                }
                newOrders.remove(at: index)
                allOrders[replaceDate] = newOrders
                try Self.saveAllOrders(allOrders)
                signal(.success(true))
            } catch {
                signal(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchRecentOrders(start: Date, end: Date? = nil) -> AnyPublisher<[BusinessDate: [Order]], Error> {
        return loadAllOrders()
            .map { fetched in
                var result = [BusinessDate: [Order]]()
                var searchDate = start
                let endDate = end ?? Date().startOfDay()
                while searchDate <= endDate {
                    let businessDate = BusinessDate(start: searchDate)
                    result[businessDate] = fetched[businessDate]
                    searchDate = Calendar.current.date(byAdding: .day, value: 1, to: searchDate)!
                }
                return result
            }.eraseToAnyPublisher()
    }
}

extension UserDefaultsRepository {
    private func saveOrders(_ orders: [Order]) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { signal in
            do {
                let orders = orders.filter { ($0.quantity ?? 0) > 0 }
                guard !orders.isEmpty else {
                    signal(.failure(LocalDataRepositoryError.emptyOrders))
                    return
                }
                
                var allOrders = UserDefaultsRepository.getAllOrders()
                let businessDay = BusinessDate(start: Date().startOfDay(), end: nil)
                
                // New ald Old
                var newOrders = orders
                var existingOrders = allOrders[businessDay] ?? []
                
                // Replace if exist
                for order in orders {
                    if let index = existingOrders.firstIndex(where: { $0.id == order.id }) {
                        existingOrders[index] = order
                        newOrders.removeAll(where: { $0.id == order.id })
                    }
                }
                
                // Append non-exist
                existingOrders += newOrders
                allOrders[businessDay] = existingOrders
                
                let toSave = try JSONEncoder().encode(allOrders)
                let result = String(data: toSave, encoding: .utf8)
                UserDefaults.standard.orders = result
                signal(.success(true))
            } catch {
                signal(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    private func loadAllOrders() -> AnyPublisher<[BusinessDate: [Order]], Error> {
        return Future<[BusinessDate: [Order]], Error> { signal in
            do {
                let orders = UserDefaults.standard.orders ?? "{}"
                let data = orders.data(using: .utf8)!
                let result = try JSONDecoder().decode([BusinessDate: [Order]].self, from: data)
                signal(.success(result))
            } catch {
                signal(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}

extension UserDefaultsRepository {
    static func getAllOrders() -> [BusinessDate: [Order]] {
        let savedOrders = UserDefaults.standard.orders ?? "{}"
        let data = savedOrders.data(using: .utf8)
        let allOrders = (try? JSONDecoder().decode([BusinessDate: [Order]].self, from: data!)) ?? [:]
        return allOrders
    }
    
    private static func saveAllOrders(_ orders: [BusinessDate: [Order]]) throws {
        let toSave = try JSONEncoder().encode(orders)
        let result = String(data: toSave, encoding: .utf8)
        UserDefaults.standard.orders = result
    }
    
    static func getAllMenus() -> [Menu] {
        let saveMenus = UserDefaults.standard.menus ?? "[]"
        let data = saveMenus.data(using: .utf8)
        let menus = (try? JSONDecoder().decode([Menu].self, from: data!)) ?? []
        return menus
    }
    
    private static func saveMenus(_ menus: [Menu]) throws {
        let toSave = try JSONEncoder().encode(menus)
        let result = String(data: toSave, encoding: .utf8)
        UserDefaults.standard.menus = result
    }
    
    static func getAllStores() -> [Store] {
        let savedStores = UserDefaults.standard.stores ?? "[]"
        let data = savedStores.data(using: .utf8)
        let stores = (try? JSONDecoder().decode([Store].self, from: data!)) ?? []
        return stores
    }
    
    private static func saveStores(_ stores: [Store]) throws {
        let toSave = try JSONEncoder().encode(stores)
        let result = String(data: toSave, encoding: .utf8)
        UserDefaults.standard.stores = result
    }
}
