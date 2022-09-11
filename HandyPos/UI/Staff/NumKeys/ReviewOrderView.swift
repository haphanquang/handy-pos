//
//  ReviewOrderView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/06/20.
//

import Foundation
import SwiftUI

struct ReviewOrderView: View, Equatable {
    @Binding var isPresented: Order?
    @ObservedObject var viewModel: OrderConfirmationViewModel
    @Binding var note: String
    
    var onRemoveItem: ((String) -> Void)?
    var onCompleteOrder: (() -> Void)?
    var onClearItems: (() -> Void)?
    
    var body: some View {
        VStack {
            VStack(spacing: .zero) {
                headerView
                itemListView
            }
            
            if let recentError = viewModel.errorMessage {
                Text(recentError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            noteView
            OrderStatusPickerView(
                statuses: viewModel.orderStatuses,
                selected: $viewModel.status
            )
            summaryView
        }
        .padding(.horizontal)
        .padding(.bottom)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink {
                    BillView(pdfData: viewModel.prepareBill())
                } label: {
                    Text("Hoá đơn")
                }
            }
        }
        .navigationTitle("Đơn hàng")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack(spacing: 4) {
            Text("Mã").frame(width: 38)
            Text("Thông tin")
            Spacer()
            Text("SL").frame(width: 25)
            Text("Thành tiền").frame(width: 110)
        }.font(.subheadline)
        .foregroundColor(.white)
        .background(
            Rectangle().fill(.black)
        )
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var itemListView: some View {
        List {
            ForEach(viewModel.sessionInfo.selected.keys) { item in
                ItemRowView(
                    item: item,
                    extraInfo: viewModel.sessionInfo[item]?.extra,
                    canChangeAmount: false,
                    amount: Binding(
                        get: { viewModel.sessionInfo[item]?.quantity ?? 0 },
                        set: { viewModel.sessionInfo[item]?.quantity = $0 }
                    )
                ).listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
            }
            .onDelete(perform: onDeleteItem(_:))
            .listRowSeparator(.hidden)
            
        }.listStyle(.plain)
    }
    
    @ViewBuilder
    private var summaryView: some View {
        VStack {
            Divider()
            HStack {
                Text("Tổng")
                Spacer()
                Text("\(viewModel.sessionInfo.totalAmount.formatted)").bold()
            }.padding(.vertical, 6)
            Divider()
        }
        
        ZStack {
            HStack {
                Button(action: onTapCompleteOrder, label: {
                    Label("Chốt đơn", systemImage: "checkmark.shield.fill").confirmStyle()
                })
            }
            HStack {
                Button(action: onTapClearItems, label: {
                    Text("Xoá đơn").foregroundColor(.red)
                })
                Spacer()
            }
        }.padding(.top, 12)
    }
    
    @ViewBuilder
    private var noteView: some View {
        OrderConfirmationNoteView(note: $note)
    }
    
    func onDeleteItem(_ offsets: IndexSet) {
        let keys = viewModel.sessionInfo.selected.keys
        for index in offsets {
            onRemoveItem?(keys[index].id)
        }
        viewModel.deleteItem(offsets: offsets)
    }
    
    func onTapCompleteOrder() {
        if viewModel.confirmOrder() {
            onCompleteOrder?()
            isPresented = nil
            DeviceFeedbacks.playPaymentSuccessfully()
        }
    }
    
    func onTapClearItems() {
        onClearItems?()
        isPresented = nil
    }
    
    static func == (lhs: ReviewOrderView, rhs: ReviewOrderView) -> Bool {
        lhs.viewModel.sessionInfo.id == rhs.viewModel.sessionInfo.id
    }
}
