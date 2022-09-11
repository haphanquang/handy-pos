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
import UIKit

struct PhonePopoverModifier<PopoverContent: View, PopOverIdenfiable: Identifiable>: ViewModifier {
    @Binding var showPopover: PopOverIdenfiable?
    var popoverSize: CGSize?
    let popoverContent: (PopOverIdenfiable) -> PopoverContent
    
    func body(content: Self.Content) -> some View {
        content.background(
            WrapperView(
                showPopover: $showPopover,
                popoverSize: popoverSize,
                popoverContent: popoverContent
            ).frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    struct WrapperView<PopoverContent: View>: UIViewControllerRepresentable {
        @Binding var showPopover: PopOverIdenfiable?
        let popoverSize: CGSize?
        let popoverContent: (PopOverIdenfiable) -> PopoverContent
        
        func makeUIViewController(
            context: UIViewControllerRepresentableContext<WrapperView<PopoverContent>>
        ) -> WrapperViewController<PopoverContent> {
            WrapperViewController(
                popoverSize: popoverSize,
                popoverContent: popoverContent
            ) {
                self.showPopover = nil
            }
        }
        
        func updateUIViewController(
            _ uiViewController: WrapperViewController<PopoverContent>,
            context: UIViewControllerRepresentableContext<WrapperView<PopoverContent>>
        ) {
            uiViewController.updateSize(popoverSize)
            if let data = showPopover {
                uiViewController.showPopover(data)
            } else {
                uiViewController.hidePopover()
            }
        }
    }
    
    class WrapperViewController<PopoverContent: View>: UIViewController, UIPopoverPresentationControllerDelegate {
        var popoverSize: CGSize?
        let popoverContent: (PopOverIdenfiable) -> PopoverContent
        let onDismiss: () -> Void
        var popoverVC: UIViewController?
        
        required init?(coder: NSCoder) { fatalError("") }
        
        init(
            popoverSize: CGSize?,
            popoverContent: @escaping (PopOverIdenfiable) -> PopoverContent,
            onDismiss: @escaping() -> Void
        ) {
            self.popoverSize = popoverSize
            self.popoverContent = popoverContent
            self.onDismiss = onDismiss
            super.init(nibName: nil, bundle: nil)
        }
        
        func showPopover(_ data: PopOverIdenfiable) {
            guard popoverVC == nil else { return }
            
            let willPresentVC = UIHostingController(rootView: popoverContent(data))
            if let size = popoverSize { willPresentVC.preferredContentSize = size }
            
            willPresentVC.modalPresentationStyle = .popover
            
            if let popover = willPresentVC.popoverPresentationController {
                popover.sourceView = view
                popover.delegate = self
            }
            popoverVC = willPresentVC
            
            // this line causes warning because self is not being attached to view hierachy
            self.present(willPresentVC, animated: false, completion: nil)
        }
        
        func hidePopover() {
            guard let vc = popoverVC, !vc.isBeingDismissed else { return }
            vc.dismiss(animated: true, completion: nil)
            popoverVC = nil
        }
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            popoverVC = nil
            self.onDismiss()
        }
        
        func updateSize(_ size: CGSize?) {
            self.popoverSize = size
            if let vc = popoverVC, let size = size {
                vc.preferredContentSize = size
            }
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none // this is what forces popovers on iPhone
        }
        
        func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
            guard let view = popoverPresentationController.containerView else {
                return
            }
            let bgView = ZebraView(frame: view.bounds)
            bgView.backgroundColor = .black.withAlphaComponent(0.6)
            view.addSubview(bgView)
        }
    }
}

extension View {
    func popover<Item, Content>(
        item: Binding<Item?>,
        size: CGSize?,
        content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable, Content: View {
        return self.modifier(PhonePopoverModifier(showPopover: item, popoverSize: size, popoverContent: content))
    }
}

private class ZebraView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let lineWidth: CGFloat = 40
        let lineCount = Int(rect.height / lineWidth)
        
        let lineLength = CGFloat(sqrt(rect.width * rect.width + rect.height * rect.height))
        
        let minX = -(lineLength - rect.width) / 2
        let maxX = (lineLength - rect.width) / 2 + rect.width
        
        UIColor.black.withAlphaComponent(0.2).setStroke()
        
        let path = UIBezierPath()
        for line in 1...lineCount where (line % 2 == 0) {
            let left = CGPoint(x: minX, y: CGFloat(line) * lineWidth)
            let right = CGPoint(x: maxX, y: CGFloat(line) * lineWidth)
            
            path.move(to: left)
            path.addLine(to: right)
            
        }
        path.apply(.init(translationX: -rect.width / 2, y: -rect.height / 2))
        path.apply(.init(rotationAngle: .pi / 4))
        path.apply(.init(translationX: rect.width / 2, y: rect.height / 2))
        path.lineWidth = lineWidth
        path.stroke()
    }
}
