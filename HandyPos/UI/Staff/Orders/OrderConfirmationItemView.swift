//
//  OrderConfirmationItemView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/05/08.
//

import Foundation
import SwiftUI

struct ItemRowView: View {
    let item: SessionItem
    let extraInfo: String?
    var canChangeAmount: Bool = true
    @Binding var amount: Int
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack(spacing: 4) {
                Text(item.code)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(item.color ?? .secondary))
                
                VStack(alignment: .leading) {
                    Text(item.name)
                        .foregroundColor(.primary)
                        .font(.subheadline.leading(.tight))
                        .lineSpacing(3)
                    Text(item.price.formatted)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                    if let extra = extraInfo {
                        Text(extra).foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: .zero) {
                    Button(action: increase) {
                        Image(systemName: "chevron.compact.up").padding(2)
                    }.buttonStyle(PlainButtonStyle())
                    
                    Text("x\(amount)")
                        .monospacedDigit()
                        .font(.body)
                        .bold()
                    
                    Button(action: decrease) {
                        Image(systemName: "chevron.compact.down").padding(2)
                    }.buttonStyle(PlainButtonStyle())
                }.disabled(!canChangeAmount)
                
                Text(item.price.multiply(by: amount).formatted)
                    .font(.subheadline)
                    .bold()
                    .monospacedDigit()
                    .frame(minWidth: 110)
                
            }.padding(.vertical, 8)
            Divider()
        }
    }
    
    private func increase() {
        amount += 1
    }
    
    private func decrease() {
        amount = max(0, amount - 1)
    }
}
