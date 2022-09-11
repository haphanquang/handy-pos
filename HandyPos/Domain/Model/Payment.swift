//
//  Payment.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/12.
//

import Foundation

enum Payment: Codable {
    case cash
    case card(CardBrand)
    case emoney
}

enum CardBrand: Codable {
    case visa
    case masterCard
    case amex
    case jcb
}
