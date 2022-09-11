//
//  OrderListView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/25.
//

import Foundation
import SwiftUI

struct OrderListView: View {
    @ObservedObject var viewModel: OrderListViewModel
    @State var isShowingFilter: Bool = false
    
    var body: some View {
        VStack {
            if isShowingFilter {
                filteringView
            }
            
            if viewModel.orders.isEmpty {
                EmptyOrderListView()
            } else {
                Form {
                    ForEach(Array(viewModel.orders.enumerated()), id: \.offset) { offset, element in
                        Section(content: {
                            Button {
                                editOrder(element)
                            } label: {
                                OrderItemView(order: element, locale: Locale(
                                    identifier: viewModel.appState.value.userData.settings.userSelectedLanguage ?? Language.vietnam.rawValue
                                ))
                            }.buttonStyle(.plain)
                        }, header: {
                            Text("Đơn thứ") + Text(" \(viewModel.orders.count - offset)")
                        })
                    }
                }
            }
        }
        .sheet(item: $viewModel.editingOrder, onDismiss: nil) { [viewModel] order in
            NavigationView {
                OrderConfirmationView(
                    viewModel: OrderConfirmationViewModel(order: order, appState: viewModel.appState)
                )
            }.navigationViewStyle(.stack)
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink {
                    GoodsGridView(
                        viewModel: GoodsGridViewModel(
                            appState: viewModel.appState,
                            mode: .normalOrder)
                    )
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    withAnimation {
                        isShowingFilter.toggle()
                    }
                } label: {
                    Image(systemName: isShowingFilter ? "chevron.up" : "chevron.down")
                }
            }
        })
        .background(Color(uiColor: UIColor.systemGroupedBackground))
        .navigationTitle(LocalizedStringKey(viewModel.dateTitle))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.transform)
    }
    
    private func editOrder(_ order: Order) {
        viewModel.editingOrder = order
    }
    
    @ViewBuilder
    var filteringView: some View {
        VStack {
            DatePicker(
                "Ngày tạo đơn",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            FilterPickerView(statuses: FilterOptions.allFilters, selected: $viewModel.orderFilter)
        }
        .padding(.top, 4)
        .padding(.horizontal)
    }
}

struct OrderItemView: View {
    let order: Order
    let locale: Locale
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                (Text("\(order.quantity ?? 0) ") + Text("món"))
                    .bold()
                    .font(.title3)
                Spacer()
                Text(order.inTime.timeAgoDisplay(locale: locale))
                    .font(.subheadline)
                    .italic()
            }.padding(.vertical, 2)
            
            Text(order.summary)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            if let note = order.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .italic()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Divider()
            }
            
            HStack {
                Text("Tổng")
                Text(order.totalPrice.formatted).bold()
                Spacer()
                OrderStatusView(status: order.status, verticalPadding: 4, selected: true)
            }
        }.contentShape(Rectangle())
    }
}

struct EmptyOrderListView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Không có đơn hàng.\nKhách hàng đang chờ mua những món hàng tốt nhất từ bạn đó.")
                .padding(.horizontal, 8)
                .multilineTextAlignment(.center)
                .font(.subheadline.italic())
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
}
