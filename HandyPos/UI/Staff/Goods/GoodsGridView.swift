//
//  GoodsGridView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/27.
//

import Foundation
import SwiftUI

public struct GoodsGridView: View {
    private let columns = Array(
        repeating: GridItem(
            .flexible(minimum: 80, maximum: UIScreen.main.preferredMode?.size.width ?? 300 / 4),
            spacing: 12,
            alignment: .center
        ),
        count: 2)
    
    @ObservedObject var viewModel: GoodsGridViewModel
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.items) { item in
                        GoodsView(
                            item: item,
                            badge: Binding(
                                get: { viewModel.session[item]?.quantity ?? 0 },
                                set: { viewModel.session[item]?.quantity = $0 }
                            )
                        )
                    }
                }
                .padding()
                .padding(.bottom, 55)
            }
            
            if viewModel.session.quantity > 0 {
                VStack {
                    Spacer()
                    Button(action: confirmOrder, label: {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Xác nhận")
                            Text("(\(viewModel.session.quantity))")
                        }.confirmStyle()
                        .animation(.linear, value: viewModel.session.quantity)
                    }).padding()
                }
            }
        }
        .searchable(
            text: $viewModel.searchString,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: "nhập từ khoá..."
        )
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.confirmingSession, onDismiss: {
            if viewModel.mode == .normalOrder { dismiss() }
        }, content: { session in
            NavigationView {
                OrderConfirmationView(
                    viewModel:
                        OrderConfirmationViewModel(
                            session: session,
                            appState: viewModel.appState,
                            isFastOrder: (viewModel.mode == .fastOrder)
                        )
                ).reviewCounter()
            }.navigationViewStyle(.stack)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.session.quantity > 0 {
                    Button("Xoá chọn", action: viewModel.resetSelection)
                }
            }
        }
    }
    
    private func confirmOrder() {
        switch viewModel.mode {
        case .addToOrder:
            viewModel.completeOrder()
            dismiss()
        default:
            viewModel.confirmOrder()
        }
    }
}
