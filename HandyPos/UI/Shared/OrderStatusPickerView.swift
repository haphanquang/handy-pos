//
//  OrderStatusPickerView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/05/02.
//

import Foundation
import SwiftUI

struct OrderStatusPickerView: View {
    let statuses: [OrderStatus]
    @Binding var selected: OrderStatus
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(statuses, id: \.self) { status in
                    Button {
                        selected = status
                    } label: {
                        if selected == status {
                            OrderStatusView(status: status, selected: true)
                        } else {
                            OrderStatusView(status: status, selected: false)
                        }
                    }
                }
            }
        }
    }
}

struct OrderStatusView: View {
    let status: OrderStatus
    var verticalPadding: CGFloat = 8
    @State var selected: Bool
    
    var body: some View {
        if selected {
            Text(status.description)
                .font(.caption)
                .bold()
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, verticalPadding * 2)
                .background(Capsule().fill(status.color.opacity(0.9)))
                .foregroundColor(.white)
        } else {
            Text(status.description)
                .font(.caption)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, verticalPadding * 2)
                .background(Capsule().strokeBorder(status.color.opacity(0.9), lineWidth: 1.5))
                .foregroundColor(status.color.opacity(0.9))
        }
        
    }
}
