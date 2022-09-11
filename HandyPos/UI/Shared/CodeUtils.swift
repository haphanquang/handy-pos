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
import UIKit
import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: UIViewRepresentable {
    let qrCode: String
    var scale: CGAffineTransform = .init(scaleX: 5, y: 5)
    
    func makeUIView(context: Context) -> UIImageView {
        let view = UIImageView()
        view.layer.magnificationFilter = .nearest
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.saveImageQRToPhotos)
        )
        longPress.minimumPressDuration = 2
        view.addGestureRecognizer(longPress)
        return view
    }
    
    func updateUIView(_ view: UIImageView, context: Context) {
        view.image = UIImage(qrcode: qrCode, scale: scale)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: QRCodeView

        init(_ parent: QRCodeView) {
            self.parent = parent
        }
        
        @objc func saveImageQRToPhotos(gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else {
                return
            }
            
            let saveScale = CGAffineTransform.init(scaleX: 10, y: 10)
            guard let image = UIImage(qrcode: parent.qrCode, scale: saveScale) else {
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            DeviceFeedbacks.playPaymentSuccessfully()
        }

    }
}
struct TapableQRCodeView: View {
    let qrCode: String
    internal let inspection = Inspection<Self>() // for unittest
    @State var isShowingBiggerQR: String?
    
    var body: some View {
        Button(action: showBiggerQR, label: {
            QRCodeView(qrCode: qrCode, scale: .init(scaleX: 3, y: 3)).fixedSize()
        }).popover(item: $isShowingBiggerQR, size: CGSize(width: 260, height: 260)) { qr in
            QRCodeView(qrCode: qr).frame(width: 250, height: 250)
        }.onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private func showBiggerQR() {
        isShowingBiggerQR = qrCode
    }
}

extension String: Identifiable {
    public var id: String { self }
}

extension UIImage {
    convenience init?(qrcode: String, scale: CGAffineTransform) {
        let data = qrcode.data(using: String.Encoding.ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        filter.setValue(data, forKey: "inputMessage")
        
        // CIImage cannot be stored in device, need to convert it to CGImage
        guard
            let output = filter.outputImage?.transformed(by: scale),
            let cgImage = CIContext().createCGImage(output, from: output.extent)
        else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
