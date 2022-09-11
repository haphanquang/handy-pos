//
//  Menu.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/12.
//

import Foundation

struct Menu: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var createdAt = Date()
    var activeDate = Date()
    var expireAt: Date?
    var pages: [MenuPage] = []
    
    var dishes: [Dish] {
        return pages.reduce(into: [Dish]()) { partialResult, page in
            return partialResult.append(contentsOf: page.dishes)
        }
    }
}

struct MenuPage: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var index: Int = 0
    var dishes: [Dish] = []
    var background: String?
    var layout: PageLayout?
}

struct PageLayout: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var layoutItem: [LayoutItem]
    
    struct LayoutItem: Codable, Hashable {
        let frame: String
        let dish: Dish
    }
}

extension Menu {
    static func fixtures() -> [Menu] {
        var page = MenuPage()
        page.dishes = Dish.fixtures()
        var menu = Menu()
        menu.pages = [page]
        return [menu]
    }
}
