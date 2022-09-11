//
//  PDFPreviewView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/04/11.
//

import Foundation
import PDFKit
import SwiftUI
import Photos

struct PDFPreviewView: UIViewRepresentable {
    typealias UIViewType = PDFView

    let document: PDFDocument?
    let singlePage: Bool

    init(_ data: Data, singlePage: Bool = false) {
        self.document = PDFDocument(data: data)
        self.singlePage = singlePage
    }

    func makeUIView(context _: UIViewRepresentableContext<PDFPreviewView>) -> UIViewType {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        if singlePage {
            pdfView.displayMode = .singlePage
        }
        return pdfView
    }

    func updateUIView(_ pdfView: UIViewType, context _: UIViewRepresentableContext<PDFPreviewView>) {
        pdfView.document = document
    }
}

struct BillView: View {
    @State var savedBill = false
    @State var savedError = false
    
    let pdfData: Data
    
    var body: some View {
        PDFPreviewView(pdfData)
            .navigationBarTitle("Hoá đơn")
            .alert("Tải hoá đơn", isPresented: $savedBill) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Thành công. Bạn hãy kiểm tra thư viện ảnh")
            }
            .alert("Lỗi", isPresented: $savedError) {
                Button("OK", role: .cancel) { }
                Button("Cài đặt") {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
            } message: {
                Text("Không thể lưu hoá đơn, xin hãy cài đặt lại quyền lưu ảnh: Cài đặt > hPOS > Ảnh")
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            let saveResult = await ImageSaver().savePdfData(pdfData)
                            if saveResult {
                                savedBill = true
                            } else {
                                savedError = true
                            }
                        }
                    } label: {
                        Text("Tải xuống")
                    }
                }
            }
    }
}

class ImageSaver: NSObject {
    func savePdfData(_ data: Data) async -> Bool {
        await withCheckedContinuation { continuation in
            guard let document = PDFDocument(data: data), let image = convertDocument(document) else {
                continuation.resume(returning: false)
                return
            }
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                if status == .authorized {
                    ImageSaver().writeToPhotoAlbum(image: image)
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    private func convertDocument(_ pdf: PDFDocument) -> UIImage? {
        guard let page = pdf.documentRef?.page(at: 1) else {
            return nil
        }
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
        return img
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc
    func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
