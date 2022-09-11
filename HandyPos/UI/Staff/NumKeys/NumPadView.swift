//
//  NumPadView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/05/22.
//

import Foundation
import SwiftUI

struct NumPadView: View {
    @StateObject var viewModel: NumPadViewModel
    @State var willUpdateNote: String?
    
    var body: some View {
        VStack(spacing: 12) {
            moneyText
            HStack {
                addNoteButton
                addItembutton
            }
            ScrollView {
                numPad.padding(4)
            }
            confirmButton
        }.alert(
            "Tạo đơn",
            isPresented: $viewModel.alertPresented,
            presenting: viewModel.currentNumber,
            actions: { price in
                Button("Huỷ", role: .cancel) { }
                Button("Xác nhận") {
                    viewModel.sendNewOrder()
                }
            }, message: { price in
                Text(LocalizedStringKey("Bán sản phẩm với số tiền: \(price.money!) ?"))
            }
        )
        .sheet(item: $viewModel.reviewingOrder, onDismiss: nil) { [viewModel] order in
            NavigationView {
                ReviewOrderView(
                    isPresented: $viewModel.reviewingOrder,
                    viewModel: OrderConfirmationViewModel(
                        session: Session(order: order),
                        appState: viewModel.appState
                    ),
                    note: $viewModel.note,
                    onRemoveItem: viewModel.removeItem(_:),
                    onCompleteOrder: viewModel.finishReviewingOrder,
                    onClearItems: viewModel.clearItems
                ).equatable()
            }
            .navigationViewStyle(.stack)
        }
        .padding(8)
    }
    
    @ViewBuilder
    var moneyText: some View {
        HStack {
            Spacer()
            Text(viewModel.moneyText)
                .font(.system(size: 45, weight: .heavy, design: .rounded))
        }
    }
    
    @ViewBuilder
    var numPad: some View {
        NumberGridView { viewModel.tap($0) }
    }
    
    @ViewBuilder
    var confirmButton: some View {
        Button {
            viewModel.onTapConfirm()
        } label: {
            Text(viewModel.actionButtonTitle)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .frame(minWidth: .zero, maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color.blue)
                )
        }
    }
    
    @ViewBuilder
    var addNoteButton: some View {
        Button {
            addNote()
        } label: {
            if viewModel.note.isEmpty {
                Text(LocalizedStringKey("\(Image(systemName: "plus")) Ghi chú"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8).strokeBorder(.gray.opacity(0.5), lineWidth: 1)
                    )
            } else {
                Text(LocalizedStringKey("\(Image(systemName: "checkmark.circle.fill")) Ghi chú"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.gray)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(.primary)
                    )
            }
            
        }
        .sheet(item: $willUpdateNote) { note in
            NavigationView {
                NoteEditor(note: note) { viewModel.note = $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .navigationTitle("Ghi chú")
                    .navigationBarTitleDisplayMode(.inline)
            }.navigationViewStyle(.stack)
        }
        .foregroundColor(.primary)
    }
    
    @ViewBuilder
    var addItembutton: some View {
        Button {
            viewModel.onTapAppendItem()
        } label: {
            Text("\(Image(systemName: "plus"))")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 88, height: 44)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
        }
    }
    
    @ViewBuilder
    var recentPriceView: some View {
        ScrollView(.horizontal) {
            HStack {
                
            }
        }
    }
    
    private func addNote() {
        willUpdateNote = viewModel.note
    }
}

struct NumberGridView: View {
    var onTap: (String) -> Void
    
    private let reduce: CGFloat = UIDevice.modelName.contains("iPhone SE") ? 40 : 25
    
    private let chars = Array("123456789").map {String($0)} + ["C", "0", "000"]
    private let col: CGFloat = 3
    private let space: CGFloat = .zero
    private let columns = [GridItem](
        repeating: .init(.flexible(), spacing: .zero, alignment: .center),
        count: 3
    )
    
    var body: some View {
        GeometryReader { gp in
            LazyVGrid(columns: columns, spacing: space) {
                ForEach(chars) { item in
                    NumberButton(
                        text: item,
                        size: CGSize(
                            width: (gp.size.width - (col - 1) * space) / col,
                            height: (gp.size.width - (col - 1) * space) / col - reduce
                        )
                    ) { onTap($0) }
                }
            }.drawingGroup()
            .overlay(
                GridLines(cols: Int(col), rows: chars.count / Int(col))
                    .stroke(
                        .gray.opacity(0.5),
                        style: StrokeStyle(lineWidth: 0.5, lineCap: .round, lineJoin: .round)
                    )
            )
        }
    }
}

struct NumberButton: View {
    let text: String
    let size: CGSize
    var onTap: (String) -> Void
    
    var body: some View {
        Button {
            onTap(text)
        } label: {
            Text(text)
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(width: size.width, height: size.height)
        }
    }
}

struct GridLines: Shape {
    let cols: Int
    let rows: Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let spaceX = rect.width / CGFloat(cols)
        let spaceY = rect.height / CGFloat(rows)
        
        for col in 1...cols-1 {
            path.move(to: CGPoint(x: rect.minX + CGFloat(col) * spaceX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + CGFloat(col) * spaceX, y: rect.maxY))
        }
        
        for row in 1...rows-1 {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + CGFloat(row) * spaceY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + CGFloat(row) * spaceY))
        }
                         
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 12, height: 12))

        return path
    }
}
 
