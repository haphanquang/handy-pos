//
//  BluetoothHandler.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/04/08.
//

import Foundation
import CoreBluetooth
import SwiftUI

class BluetoothHandler: NSObject {
    private var centralManager: CBCentralManager!
    private var appState: AppState!
    private let updateQueue = DispatchQueue(label: "com.soyo.handy-pos.core.bluetooth")
    
    required convenience init(appState: AppState) {
        self.init()
        self.appState = appState
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: updateQueue)
    }
    
    func printPdf(data: Data) {
        
    }
}

extension BluetoothHandler: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            return
        case .resetting:
            return
        case .unsupported:
            return
        case .unauthorized:
            return
        case .poweredOff:
            centralManager?.stopScan()
            return
        case .poweredOn:
            centralManager.scanForPeripherals(
                withServices: nil,
                options: nil
            )
            return
        @unknown default:
            return
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        if let name = peripheral.name {
            print(peripheral)
            print(RSSI)
            
            if name == "M02 Pro" {
                central.connect(peripheral)
                central.stopScan()
            }
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        print("Connected")
        print(peripheral)
    }
}

protocol Printer {
    func write(bytes: Data)
    func read(count: Int) -> Data
}
