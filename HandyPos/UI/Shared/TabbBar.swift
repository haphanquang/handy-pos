/*
* Copyright (c) Rakuten Payment, Inc. All Rights Reserved.
*
* This program is the information asset which are handled
* as "Strictly Confidential".
* Permission of use is only admitted in Rakuten Payment, Inc.
* If you don't have permission, MUST not be published,
* broadcast, rewritten for broadcast or publication
* or redistributed directly or indirectly in any medium.
*/

import Foundation
import SwiftUI

struct TabbItem: Hashable, Identifiable, Equatable {
    var id: Int { self.hashValue }
    var title: String
    var imageName: String
    var rotationType: RotateType = .normal
    var badge: Int = 0
    
    enum RotateType {
        case normal
        case threeD
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(imageName)
        hasher.combine(rotationType)
    }
    
    static func == (lhs: TabbItem, rhs: TabbItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

struct TabbBar: View {
    let tabs: [TabbItem]
    @Binding private var selectedItem: TabbItem
    
    init?(tabs items: [TabbItem], selected: Binding<TabbItem>) {
        guard items.count > 0 else { return nil }
        tabs = items
        _selectedItem = selected
    }
    
    var body: some View {
        HStack {
            ForEach(tabs, id: \.title) { item in
                TabbItemView(
                    item: item,
                    isSelected: createBindingFor(item)
                )
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .background(
            Color(UIColor.tertiarySystemBackground).edgesIgnoringSafeArea(.bottom)
        )
        .onAppear {
            DeviceFeedbacks.prepare()
        }
    }
    
    private func createBindingFor(_ item: TabbItem) -> Binding<Bool> {
        Binding(
            get: { selectedItem == item },
            set: { isSelected in
                if isSelected {
                    selectedItem = item
                    DeviceFeedbacks.playSelected()
                }
            }
        )
    }
}

struct TabbItemView: View {
    let item: TabbItem
    @Binding var isSelected: Bool
    @State private var isRotated: Bool = false
    
    internal let inspection = Inspection<Self>() // for unittest
    
    var body: some View {
        Button(action: {
            isSelected = true
        }, label: {
            if isSelected {
                createSelectedView()
            } else {
                createNormalView()
            }
        })
        .frame(minWidth: 55)
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    @ViewBuilder
    private func createSelectedView() -> some View {
        ZStack {
            Capsule().fill(Color.black)
            HStack(spacing: 5) {
                Image(systemName: item.imageName)
                    .foregroundColor(Color.white)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .rotate(item.rotationType, when: isRotated)
                    .animation(animation, value: isRotated)
                    .onAppear { isRotated.toggle() }
                Text(LocalizedStringKey(item.title))
                    .foregroundColor(Color.white)
                    .font(.caption)
                    .bold()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .layoutPriority(1)
            
            if item.badge > 0 {
                badgeView.transformEffect(.init(translationX: 0, y: -5))
            }
        }
    }
    
    @ViewBuilder
    private func createNormalView() -> some View {
        ZStack {
            Image(systemName: item.imageName)
                .foregroundColor(.secondary)
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
                .padding()
                .layoutPriority(1)
            if item.badge > 0 {
                badgeView
            }
        }
    }
    
    @ViewBuilder
    var badgeView: some View {
        HStack {
            Spacer()
            VStack {
                Text("\(item.badge)")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .background(Capsule().fill(.green))
                Spacer()
            }
        }
    }
    
    private let animation = Animation.interactiveSpring(response: 0.9, dampingFraction: 0.6, blendDuration: 1)
}

private struct AnimationSwitchModifier: ViewModifier {
    let animationType: TabbItem.RotateType
    let isRotated: Bool
    
    func body(content: Content) -> some View {
        if animationType == .normal {
            content.rotationEffect(.degrees(isRotated ? 360 : 0))
        } else {
            content.rotation3DEffect(.degrees(isRotated ? 360 : 0), axis: (x: 1, y: 0, z: 0))
        }
    }
}
private extension View {
    func rotate(_ type: TabbItem.RotateType, when: Bool) -> some View {
        modifier(AnimationSwitchModifier(animationType: type, isRotated: when))
    }
}
