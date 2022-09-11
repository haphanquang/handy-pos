//
//  Store.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/31.
//

import Foundation

struct Store: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String = "Chưa đặt tên cửa hàng"
    var logo: String?
    var address1: String?
    var address2: String?
    var phoneNumber: String?
    var zipCode: String?
    var billNote: String? = "Chúc một ngày tốt lành"
}

extension Store: Equatable { }
