//
//  GoodsView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/27.
//

import Foundation
import SwiftUI

struct GoodsView: View {
    @Binding var badge: Int
    private let item: SessionItem
    
    init(item: SessionItem, badge: Binding<Int>) {
        self.item = item
        _badge = badge
    }
    
    public var body: some View {
        Button {
            increase()
        } label: {
            ZStack {
                VStack(spacing: .zero) {
                    HStack {
                        Text(item.code)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    Spacer()
                    Text(item.name)
                        .font(.subheadline)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack {
                        if badge > 0 {
                            Button(action: clear, label: {
                                Image(systemName: "trash")
                                    .font(.body)
                                    .foregroundColor(.red)
                            })
                        }
                        Spacer()
                        Text(item.price.formatted)
                            .font(.body)
                            .bold()
                            .foregroundColor(.primary)
                    }
                }
                .frame(minHeight: 99)
                .padding(8)
                .background(backgroundView)
                if badge > 0 { badgeView }
            }
        }
        
    }
    @ViewBuilder
    var badgeView: some View {
        HStack {
            Spacer()
            VStack {
                Text("\(badge)")
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.red))
                    .transformEffect(.init(translationX: 10, y: -10))
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.background)
                .shadow(radius: 1)
            VStack {
                Spacer()
                if let color = item.color {
                    Rectangle()
                        .fill(color)
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                }
            }.clipShape(RoundedRectangle(cornerRadius: 8))
            
            if badge > 0 {
                RoundedRectangle(cornerRadius: 8).strokeBorder(.red.opacity(0.5))
            }
        }
    }
    
    private func clear() { badge = 0 }
    private func increase() { badge += 1 }
}
