//
//  RealmRepository.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/02/07.
//

import Foundation
import Combine
import RealmSwift

// MARK: Todo
struct RealmRepository: Equatable {
    private let realm: Realm?
    init() {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Database")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        
        var configuration = Realm.Configuration(
            schemaVersion: Settings.currentVersion
        ) { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 { }
        }
        configuration.fileURL = url.appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = configuration
        
        do {
            self.realm = try Realm()
        } catch {
            self.realm = nil
            print("Error with realm init")
        }
    }
    
    func reset() {
        do {
            try realm?.write {
                self.realm?.deleteAll()
            }
        } catch {
            print("Could not reset now")
        }
    }
}

extension RealmRepository: LocalDataRespository {
    func fetchCurrentStore() -> AnyPublisher<Store, Error> {
        Future<Store, Error> { signal in
            guard let object = realm?.objects(RealmStore.self).first else {
                signal(.failure(LocalDataRepositoryError.notFound))
                return
            }
            signal(.success(object.toDomainObject()))
        }.eraseToAnyPublisher()
    }
    
    func updateStore(_ store: Store) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { signal in
            do {
                try realm?.write {
                    realm?.add(RealmStore.fromDomainObject(store), update: .modified)
                }
                signal(.success(true))
            } catch {
                signal(.failure(LocalDataRepositoryError.db))
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchActiveMenu() -> AnyPublisher<Menu, Error> {
        Future<Menu, Error> { signal in
            guard let object = realm?.objects(RealmMenu.self).sorted(by: \.activeDate).last else {
                signal(.failure(LocalDataRepositoryError.notFound))
                return
            }
            signal(.success(object.toDomainObject()))
        }.eraseToAnyPublisher()
    }
    
    func updateMenu(_ menu: Menu) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { signal in
            guard let realm = realm else {
                signal(.failure(LocalDataRepositoryError.db))
                return
            }
            do {
                try realm.write {
                    realm.add(RealmMenu.fromDomainObject(menu), update: .modified)
                }
                signal(.success(true))
            } catch {
                signal(.failure(LocalDataRepositoryError.unknown))
            }
        }.eraseToAnyPublisher()
    }

    func fetchTodayOrders() -> AnyPublisher<[Order], Error> {
        Future<[Order], Error> { signal in
            guard let realm = self.realm else {
                signal(.failure(LocalDataRepositoryError.db))
                return
            }
            signal(
                .success(
                    realm.objects(RealmOrder.self)
                        .filter { Calendar.current.isDateInToday($0.inTime) }
                        .map { $0.toDomainObject() }
                )
            )
        }.eraseToAnyPublisher()
    }

    func fetchOrders(on date: Date) -> AnyPublisher<[Order], Error> {
        Future<[Order], Error> { signal in
            guard let realm = self.realm else {
                signal(.failure(LocalDataRepositoryError.db))
                return
            }
            signal(
                .success(
                    realm.objects(RealmOrder.self)
                        .filter { Calendar.current.isDate($0.inTime, inSameDayAs: date) }
                        .map { $0.toDomainObject() }
                )
            )
        }.eraseToAnyPublisher()
    }

    func insertOrder(_ order: Order) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { signal in
            do {
                try realm?.write {
                    let dishes = order.orderItems?.flatMap { $0.dishes.keys }
                        .map { RealmDish.fromDomainObject($0) } ?? []
                    realm?.add(dishes, update: .modified)
                    realm?.add(RealmOrder.fromDomainObject(order), update: .modified)
                }
                signal(.success(true))
            } catch {
                signal(.failure(LocalDataRepositoryError.unknown))
            }
        }.eraseToAnyPublisher()
    }

    func updateOrder(_ order: Order) -> AnyPublisher<Bool, Error> {
        return insertOrder(order)
    }

    func deleteOrder(_ order: Order) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { signal in
            guard let realmOrder = realm?.object(ofType: RealmOrder.self, forPrimaryKey: order.id) else {
                signal(.failure(LocalDataRepositoryError.notFound))
                return
            }
            do {
                try realm?.write { realm?.delete(realmOrder) }
                signal(.success(true))
            } catch {
                signal(.failure(LocalDataRepositoryError.unknown))
            }
        }.eraseToAnyPublisher()
    }

    func fetchRecentOrders(start: Date, end: Date? = nil) -> AnyPublisher<[BusinessDate: [Order]], Error> {
        Future<[BusinessDate: [Order]], Error> { signal in
            guard let realm = self.realm else {
                signal(.failure(LocalDataRepositoryError.db))
                return
            }
            
            let orders = realm
                .objects(RealmOrder.self)
                .filter { order -> Bool in
                    var flag = order.inTime > start.startOfDay()
                    if flag == true, let end = end {
                        flag = (order.inTime < end.startOfDay())
                    }
                    return flag
                }
            var result = [BusinessDate: [Order]]()
            for order in orders {
                let bDayte = BusinessDate(start: order.inTime.startOfDay())
                var array = result[bDayte] ?? []
                array.append(order.toDomainObject())
                result[bDayte] = array
            }
            signal(.success(result))
        }.eraseToAnyPublisher()
    }
}
