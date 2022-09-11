//
//  FileDataRepository.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/01/24.
//

import Foundation
import Combine

protocol FileDataRespository { }

struct FileDataRepositoryImplement: FileDataRespository, Equatable {
    private let storage = "Storage"
    private let menuFolder = "Menu"
    private let orderFolder = "Orders"
    
    private static let plistEncoder = PropertyListEncoder()
    private static let plistDecoder = PropertyListDecoder()
    private let fileNameDateFormatter = DateFormatter()
    
    init() {
        fileNameDateFormatter.dateFormat = "yyyyMMdd"
        let menus = URL.documentUrl.appendingPathComponent(storage).appendingPathComponent(menuFolder)
        let orders = URL.documentUrl.appendingPathComponent(storage).appendingPathComponent(orderFolder)
        
        try? FileManager.default.createDirectory(
            at: menus,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.complete])
        
        try? FileManager.default.createDirectory(
            at: orders,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.complete])
        
        print("✅ \(URL.documentUrl.appendingPathComponent(storage).path)")
    }
    
    func readMenus() -> AnyPublisher<[Menu], Error> {
        return Future { signal in
            let menusPath = URL.documentUrl
                .appendingPathComponent(storage)
                .appendingPathComponent(menuFolder)
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: menusPath.path)
                var result = [Menu]()
                for file in files {
                    guard file.contains("plist") else { continue }
                    let filePath = menusPath.appendingPathComponent(file)
                    let data = try Data(contentsOf: filePath)
                    let menu = try Self.plistDecoder.decode(Menu.self, from: data)
                    result.append(menu)
                }
                signal(.success(result))
            } catch {
                signal(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func writeMenu(_ menu: Menu) -> AnyPublisher<Bool, Error> {
        return Future { signal in
            let filePathToSave = URL.documentUrl
                .appendingPathComponent(storage)
                .appendingPathComponent(menuFolder)
                .appendingPathComponent(menu.id)
                .appendingPathExtension("plist")
            do {
                let data = try Self.plistEncoder.encode(menu)
                try data.write(to: filePathToSave)
                signal(.success(true))
            } catch {
                signal(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func readOrders(_ date: Date) -> AnyPublisher<[Order], Error> {
        return Future { signal in
            let fileName = fileNameDateFormatter.string(from: date)
            let filePath = URL.documentUrl
                .appendingPathComponent(storage)
                .appendingPathComponent(orderFolder)
                .appendingPathComponent(fileName)
                .appendingPathExtension("plist")
            do {
                let data = try Data(contentsOf: filePath)
                let orders = try Self.plistDecoder.decode([Order].self, from: data)
                signal(.success(orders))
            } catch {
                signal(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func writeOrders(_ orders: [Order], at date: Date) -> AnyPublisher<Bool, Error> {
        return Future { signal in
            let fileName = fileNameDateFormatter.string(from: date)
            let filePathToSave = URL.documentUrl
                .appendingPathComponent(storage)
                .appendingPathComponent(orderFolder)
                .appendingPathComponent(fileName)
                .appendingPathExtension("plist")
            do {
                let data = try Self.plistEncoder.encode(orders)
                try data.write(to: filePathToSave)
                signal(.success(true))
            } catch {
                signal(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}

extension URL {
    static var documentUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
