//
//  PDFBuilder.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/04/10.
//

import Foundation
import PDFKit

enum Fonts {
    static let text = UIFont.init(name: "AmericanTypewriter", size: 6)!
    static let textBold = UIFont.init(name: "AmericanTypewriter-Semibold", size: 6)!
    static let sum = UIFont.init(name: "AmericanTypewriter-Bold", size: 7)!
    static let itemTitle = UIFont.init(name: "AmericanTypewriter-Semibold", size: 7)!
    static let title = UIFont.init(name: "AmericanTypewriter-Bold", size: 8)!
}

struct PDFBuilder {
    private let pageWidth: CGFloat = 2.08
    private let fixedLinesCount: CGFloat = 15
    private let charsInLine: CGFloat = 133
    private let itemMaxLineCcount = 25
    
    private let store: Store
    private let order: Order
    private let dateFormatter: DateFormatter
    
    init(store: Store, order: Order) {
        self.store = store
        self.order = order
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm EEEE, dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "vi_VN")
    }
    
    private func getPageSize() -> CGRect {
        let pWidth = pageWidth * Configuration.pointMultiple
        var itemRowCount = 0
        for item in order.mergedItems.keys {
            if item.name.count > itemMaxLineCcount {
                itemRowCount += 2
            } else {
                itemRowCount += 1
            }
        }
        
        let pHeight = getLineHeight(Fonts.title)
        + (3 + fixedLinesCount + CGFloat(itemRowCount)) * getLineHeight(Fonts.text)
        + Configuration.padding * 2
        
        return CGRect(x: 0, y: 0, width: pWidth, height: pHeight)
    }
    
    private func getLineHeight(_ font: UIFont?, text: String = "Sample String") -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font
        ]
        let attributedText = NSAttributedString(
            string: text,
            attributes: textAttributes as [NSAttributedString.Key: Any]
        )
        let textStringSize = attributedText.size()
        let textRect = CGRect(
            x: Configuration.padding,
            y: Configuration.lineSpacing,
            width: pageWidth * Configuration.pointMultiple - Configuration.padding * 2,
            height: textStringSize.height
        )
        return textRect.origin.y + textRect.size.height
    }
    
    func makePDFData() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "hPOS - quản lý bán hàng",
            kCGPDFContextAuthor: "©Soyo2020"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageRect = getPageSize()
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            var currentY: CGFloat = 0
            
            // store info rows
            currentY = addTitle(store.name, pageRect: pageRect)
            if let address1 = store.address1 {
                currentY = addRow(address1, pageRect, currentY)
            } else {
                currentY = addRow("<chưa cài đặt địa chỉ>", pageRect, currentY)
            }
            if let address2 = store.address2 {
                currentY = addRow(address2, pageRect, currentY)
            }
            if let phone = store.phoneNumber {
                currentY = addPair("Điện thoại: ", phone, pageRect, currentY)
            } else {
                currentY = addRow("Điện thoại: <chưa cài đặt>", pageRect, currentY)
            }
            
            // 6 top rows
            currentY = addSeparator("=", pageRect, currentY)
            currentY = addPair("Hoá đơn số: ", "\(Int(order.inTime.timeIntervalSince1970))", pageRect, currentY)
            currentY = addPair("Lúc: ", "\(dateFormatter.string(from: order.inTime))", pageRect, currentY)
            currentY = addSeparator("=", pageRect, currentY)
            currentY = addItem("Món", amount: "SL", price: "Đơn giá", pageRect, currentY, Fonts.itemTitle)
            currentY = addSeparator("-", pageRect, currentY)
            
            // orders row
            for (dish, quantity) in order.mergedItems {
                currentY = addItem(
                    dish.name, amount: "\(quantity)", price: dish.price.formatted, pageRect, currentY
                )
            }
            
            // 9 bottom rows
            currentY = addSeparator(" ", pageRect, currentY)
            currentY = addSeparator(" ", pageRect, currentY)
            currentY = addSeparator("-", pageRect, currentY)
            currentY = addSum("Tổng tạm tính", order.totalPrice.formatted, pageRect, currentY)
            currentY = addSeparator("=", pageRect, currentY)
            currentY = addSum("Thành tiền", order.totalPrice.formatted, pageRect, currentY, Fonts.sum)
            currentY = addSeparator("=", pageRect, currentY)
            currentY = addRow(store.billNote ?? "Chúc một ngày tốt lành", pageRect, currentY, .center)
            currentY = addRow("<<hPOS>>", pageRect, currentY, .center)
        }
        
        return data
    }
    
    func addTitle(_ text: String, pageRect: CGRect) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let titleAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: Fonts.title
        ]
        
        let attributedTitle = NSAttributedString(
            string: text,
            attributes: titleAttributes as [NSAttributedString.Key: Any]
        )
        let titleStringSize = attributedTitle.size()
        
        let titleStringRect = CGRect(
            x: Configuration.padding,
            y: Configuration.padding,
            width: titleStringSize.width,
            height: titleStringSize.height
        )
        attributedTitle.draw(in: titleStringRect)
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addRow(_ text: String, _ rect: CGRect, _ top: CGFloat, _ align: NSTextAlignment = .natural) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = align
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        return addText(text, style: paragraphStyle, rect, top)
    }
    
    func addItem(
        _ name: String,
        amount: String,
        price: String,
        _ rect: CGRect,
        _ top: CGFloat,
        _ font: UIFont = Fonts.text
    ) -> CGFloat {
        let amountTab = NSTextTab(textAlignment: .center, location: 90)
        let priceTab = NSTextTab(textAlignment: .right, location: charsInLine)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        paragraphStyle.tabStops = [amountTab, priceTab]
        
        if name.count > itemMaxLineCcount {
            let words = name.components(separatedBy: " ")
            var count = words[0].count
            for index in 1..<words.count {
                if count + words[index].count > itemMaxLineCcount {
                    break
                }
                count += (words[index].count + 1)
            }
            let nameFirstRow = name.prefix(count)
            let nameLastRow = name.suffix(name.count - count)
            let firstRow = addText("\(nameFirstRow)\t\(amount)\t\(price)", style: paragraphStyle, rect, top, font)
            let secondRow = addText(" \(nameLastRow)", style: paragraphStyle, rect, firstRow, font)
            return secondRow
        } else {
            return addText("\(name)\t\(amount)\t\(price)", style: paragraphStyle, rect, top, font)
        }
    }
    
    func addSeparator(_ char: String, _ rect: CGRect, _ top: CGFloat) -> CGFloat {
        let endTab = NSTextTab(textAlignment: .right, location: charsInLine)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        paragraphStyle.tabStops = [endTab]
        
        return addText([String](repeating: char, count: 130).joined(), style: paragraphStyle, rect, top)
    }
    
    func addSum(
        _ text: String,
        _ price: String,
        _ rect: CGRect,
        _ top: CGFloat,
        _ font: UIFont = Fonts.text
    ) -> CGFloat {
        let endTab = NSTextTab(textAlignment: .right, location: charsInLine)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        paragraphStyle.tabStops = [endTab]
        
        return addText("\(text)\t\(price)", style: paragraphStyle, rect, top, font)
    }
    
    private func addText(
        _ text: String,
        style: NSParagraphStyle,
        _ rect: CGRect,
        _ top: CGFloat,
        _ font: UIFont = Fonts.text
    ) -> CGFloat {
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.font: font
        ]
        let attributedText = NSAttributedString(
            string: text,
            attributes: textAttributes as [NSAttributedString.Key: Any]
        )
        let textStringSize = attributedText.size()
        let textRect = CGRect(
            x: Configuration.padding,
            y: top + Configuration.lineSpacing,
            width: rect.width - Configuration.padding * 2,
            height: textStringSize.height
        )
        attributedText.draw(in: textRect)
        return textRect.origin.y + textRect.size.height
    }
    
    private func addPair(
        _ name: String,
        _ value: String,
        _ rect: CGRect,
        _ top: CGFloat
    ) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let nameAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: Fonts.text
        ]
        let valueAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: Fonts.textBold
        ]
        
        let attributedText = NSMutableAttributedString(
            string: name,
            attributes: nameAttributes as [NSAttributedString.Key: Any]
        )
        attributedText.append(NSAttributedString(
            string: value,
            attributes: valueAttributes as [NSAttributedString.Key: Any]
        ))
        
        let textStringSize = attributedText.size()
        let textRect = CGRect(
            x: Configuration.padding,
            y: top + Configuration.lineSpacing,
            width: rect.width - Configuration.padding * 2,
            height: textStringSize.height
        )
        attributedText.draw(in: textRect)
        return textRect.origin.y + textRect.size.height
    }
}

extension PDFBuilder {
    enum Configuration {
        static let pointMultiple: CGFloat = 72
        static let padding: CGFloat = 8
        static let lineSpacing: CGFloat = 2
    }
}
