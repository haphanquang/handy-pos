//
//  OrderStatusFilter.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/05/02.
//

import Foundation
import SwiftUI

struct FilterOptions: OptionSet {
    let rawValue: Int

    static let new = FilterOptions(rawValue: 1 << 0)
    static let preparing = FilterOptions(rawValue: 1 << 1)
    static let serving = FilterOptions(rawValue: 1 << 2)
    static let finished = FilterOptions(rawValue: 1 << 3)
    static let cancelled = FilterOptions(rawValue: 1 << 4)
    static let delivering = FilterOptions(rawValue: 1 << 5)

    static let all: FilterOptions = [.new, .preparing, .serving, .finished, .cancelled, delivering]
    static let allFilters: [FilterOptions] = [
        .all, .new, .preparing, .serving, .finished, .cancelled, .delivering
    ]
    
    var description: LocalizedStringKey {
        if self.contains(.all) { return LocalizedStringKey("Tất cả") }
        if let status = self.matchingStatus { return status.description }
        return LocalizedStringKey("Tuỳ chọn")
    }
    
    var color: Color {
        if let status = self.matchingStatus {
            return status.color
        }
        return Color.black
    }
    
    var matchingStatus: OrderStatus? {
        switch self {
        case .new: return OrderStatus.new
        case .preparing: return OrderStatus.preparing
        case .serving: return OrderStatus.serving
        case .finished: return OrderStatus.finished
        case .cancelled: return OrderStatus.cancelled
        case .delivering: return OrderStatus.delivering
        default: return nil
        }
    }
    
    func apply(on orders: [Order]) -> [Order] {
        var result = [Order]()
        for order in orders {
            if order.status == .new && self.contains(.new)
                || order.status == .preparing && self.contains(.preparing)
                || order.status == .serving && self.contains(.serving)
                || order.status == .finished && self.contains(.finished)
                || order.status == .cancelled && self.contains(.cancelled)
                || order.status == .delivering && self.contains(.delivering) {
                result.append(order)
            }
        }
        return result
    }
}

struct FilterPickerView: View {
    let statuses: [FilterOptions]
    @Binding var selected: FilterOptions
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(statuses, id: \.rawValue) { status in
                    Button {
                        if selected.contains(status) {
                            selected.remove(status)
                        } else {
                            selected.insert(status)
                        }
                    } label: {
                        FilterSelectView(
                            status: status,
                            selected: Binding { selected.contains(status) } set: { _ in }
                        )
                    }
                }
            }
        }
    }
}

struct FilterSelectView: View {
    let status: FilterOptions
    @Binding var selected: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
            Text(status.description)
                .font(.caption)
                .bold()
                .padding(.vertical, 8)
                .padding(.trailing, 4)
        }
        .padding(.horizontal, 8)
        .background(Capsule().fill(.white))
        .foregroundColor(status.color.opacity(0.9))
    }
}
