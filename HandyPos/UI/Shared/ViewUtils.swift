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

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

extension View {
    func testableSheet<Item, Sheet>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        content: @escaping (Item) -> Sheet
    ) -> some View where Item: Identifiable, Sheet: View {
        return self.modifier(InspectableSheetWithItem(item: item, onDismiss: onDismiss, popupBuilder: content))
    }
    
    func testableSheet2<Sheet>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        content: @escaping () -> Sheet
    ) -> some View where Sheet: View {
        return self.modifier(InspectableSheet(isPresented: isPresented, onDismiss: onDismiss, popupBuilder: content))
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct InspectableSheetWithItem<Item, Sheet>: ViewModifier where Item: Identifiable, Sheet: View {
    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let popupBuilder: (Item) -> Sheet
    
    func body(content: Self.Content) -> some View {
        content.sheet(item: item, onDismiss: onDismiss, content: popupBuilder)
    }
}

struct InspectableSheet<Sheet>: ViewModifier where Sheet: View {
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let popupBuilder: () -> Sheet
    
    func body(content: Self.Content) -> some View {
        content.sheet(isPresented: isPresented, onDismiss: onDismiss, content: popupBuilder)
    }
}

extension View {
    func shakeOnAppear() -> some View {
        modifier(SimpleShakeModifier())
    }
}

private struct ShakeEffect: GeometryEffect {
    init(count: Int) {
        shakesCount = CGFloat(count)
    }
    
    private var shakesCount: CGFloat
    var animatableData: CGFloat {
        get { shakesCount }
        set { shakesCount = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let angle = .pi / 6 * sin(shakesCount * 2 * .pi)
        // Rotate with center as anchor point is combination of 3 transforms
        return ProjectionTransform(
            CGAffineTransform(translationX: -size.width / 2, y: -size.height / 2)
                .concatenating(CGAffineTransform(rotationAngle: angle))
                .concatenating(CGAffineTransform(translationX: size.width / 2, y: size.height / 2))
        )
    }
}

private struct SimpleShakeModifier: ViewModifier {
    @State var shaking: Bool = false
    
    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(count: shaking ? 2 : 0))
            .animation(Animation.linear, value: 1)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() +  0.5, execute: {
                    shaking.toggle()
                })
            }
    }
}

extension View {
    func confirmStyle() -> some View {
        self.modifier(ConfirmButtonModifier())
    }
}

private struct ConfirmButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(Capsule().fill(.green).shadow(color: .gray, radius: 1, x: 0, y: 1))
    }
}
