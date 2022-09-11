//
//  Customer.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/12.
//

import Foundation

struct Customer: Codable, Identifiable, Hashable {
    let id: String
    let name: String?
    let gender: Int?
}
