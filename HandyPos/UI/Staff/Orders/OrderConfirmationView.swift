//
//  OrderConfirmationView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/28.
//

import Foundation
import SwiftUI

struct OrderConfirmationView: View {
    @ObservedObject var viewModel: OrderConfirmationViewModel
    @State var deleteOrderConfirmAlert = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            VStack(spacing: .zero) {
                headerView
                itemListView
            }
            
            if let recentError = viewModel.errorMessage {
                Text(recentError).font(.caption)
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
        .alert(isPresented: $deleteOrderConfirmAlert) {
            createConfirmAlert()
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
                    amount: Binding(
                        get: { viewModel.sessionInfo[item]?.quantity ?? 0 },
                        set: { viewModel.sessionInfo[item]?.quantity = $0 }
                    )
                ).listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
            }
            .onDelete(perform: viewModel.deleteItem(offsets:))
            .listRowSeparator(.hidden)
            
            if viewModel.isUpdatingOrder {
                NavigationLink {
                    GoodsGridView(
                        viewModel: GoodsGridViewModel(
                            appState: viewModel.appState,
                            mode: .addToOrder(Session()),
                            onCompleted: addNewItemsIn(_:)
                        )
                    )
                } label: {
                    HStack {
                        (Text("\(Image(systemName: "plus.circle.fill")) ") + Text("Thêm món"))
                            .font(.subheadline)
                            .italic()
                        Spacer()
                    }
                }
                .listRowSeparator(.hidden)
                .padding(.trailing, -32.0)
            }
            
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
                Button(action: completeOrder, label: {
                    Label(
                        viewModel.isUpdatingOrder ? "Cập nhật" : "Chốt đơn",
                        systemImage: "checkmark.shield.fill"
                    ).confirmStyle()
                })
            }
            if viewModel.isUpdatingOrder {
                HStack {
                    Button(action: deleteOrder, label: {
                        Text("Xoá đơn").foregroundColor(.red)
                    })
                    Spacer()
                }
            }
        }.padding(.top, 12)
    }
    
    @ViewBuilder
    private var noteView: some View {
        OrderConfirmationNoteView(note: $viewModel.note)
    }
    
    private func createConfirmAlert() -> Alert {
        Alert(
            title: Text("Xoá đơn"),
            // swiftlint:disable:next:line
            message: Text("Đơn hàng sẽ bị xoá khỏi danh sách và không thể khôi phục. Bạn có chắc chắn?"),
            primaryButton: .default(
                Text("Đợi chút")
            ),
            secondaryButton: .destructive(
                Text("Tiếp tục"),
                action: {
                    viewModel.deleteOrder()
                    dismiss()
                }
            )
        )
    }
    
}
extension OrderConfirmationView {
    func completeOrder() {
        if viewModel.confirmOrder() {
            dismiss()
            DeviceFeedbacks.playPaymentSuccessfully()
        }
    }
    
    func deleteOrder() {
        deleteOrderConfirmAlert = true
    }
    
    func addNewItemsIn(_ selected: Session) {
        self.viewModel.merge(selected)
    }
}
