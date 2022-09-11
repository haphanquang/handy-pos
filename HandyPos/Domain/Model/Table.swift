//
//  Table.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/12.
//

import Foundation

struct Table {
    let id: String
    var name: String?
    var shop: String?
    var capacity: Int = 1
    var tableMenu: Menu
    var qr: String?
}
