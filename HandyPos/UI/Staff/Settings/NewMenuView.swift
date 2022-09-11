//
//  NewMenuView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/01/02.
//

import Foundation
import SwiftUI

struct NewMenuView: View {
    @ObservedObject var viewModel: NewMenuViewModel
    @Environment(\.dismiss) var dismiss
    
    private enum Field: Int, CaseIterable {
        case name, code, price, estimatedCost, note
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        Form {
            Section {
                HeaderTextField("Tên món", text: $viewModel.name)
                    .focused($focusedField, equals: .name)
                HeaderTextField("Mã", text: $viewModel.code)
                    .focused($focusedField, equals: .code)
                HeaderTextField("Giá bán", text: $viewModel.price)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .price)
                HeaderTextField("Giá gốc (đã bao gồm chi phí)", text: $viewModel.estimatedCost)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .estimatedCost)
                HStack {
                    ColorPicker("Màu nhận diện", selection: $viewModel.color)
                    Button("Mặc định", action: {
                        viewModel.color = .gray
                    })
                }
                
                HeaderTextField("Ghi chú", text: $viewModel.note)
                    .focused($focusedField, equals: .note)
            }.buttonStyle(.borderless)
            
            if viewModel.initialDish != nil {
                Button("Xoá", action: onTapDelete).foregroundColor(.red)
            }
        }
        .toolbar(content: {
            Button("Lưu", action: onTapSave).foregroundColor(.green)
        })
        .navigationTitle(viewModel.initialDish == nil ? "Thêm mới" : "Thay đổi")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func onTapSave() {
        focusedField = nil
        if viewModel.save() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                dismiss()
            }
        }
    }
    
    private func onTapDelete() {
        viewModel.delete()
        dismiss()
    }
}

class NewMenuViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var code: String = ""
    @Published var color: Color = .gray
    @Published var price: String = "0"
    @Published var estimatedCost: String = "0"
    @Published var note: String = ""
    
    let appState: AppState
    let initialDish: Dish?
    
    init(appState: AppState, dish: Dish?) {
        self.appState = appState
        self.initialDish = dish
        
        if let dish = dish {
            self.name = dish.name
            self.code = dish.code
            self.color = dish.color ?? .gray
            self.price = String(format: "%d", Int(dish.price.amount))
            self.estimatedCost = String(format: "%d", Int(dish.estimatedCost?.amount ?? 0))
            self.note = dish.description ?? ""
        }
        
        self.transform()
    }
    
    func transform() {
        $code
            .removeDuplicates()
            .map { String($0.uppercased().prefix(4)) }
            .debounce(for: 0.15, scheduler: RunLoop.main, options: nil)
            .assign(to: &$code)
    }
    
    func save() -> Bool {
        guard validateFields() else { return false }
        if var dish = initialDish {
            dish.name = name
            dish.code = code
            dish.color = color
            dish.price = Price(amount: Double(price) ?? 0)
            dish.estimatedCost = Price(amount: Double(estimatedCost) ?? 0)
            dish.description = note.isEmpty ? nil : note
            
            appState.bulkUpdate { state in
                var dishes = state.userData
                    .activeMenu
                    .pages[0]
                    .dishes
                
                let index = dishes.firstIndex(where: {$0.id == dish.id })!
                dishes.replaceSubrange(index...index, with: [dish])
                
                state.userData.activeMenu.pages[0].dishes = dishes
            }
        } else {
            let dish = Dish(
                id: UUID().uuidString,
                name: name,
                code: code,
                price: Price(amount: Double(price) ?? 0),
                estimatedCost: Price(amount: Double(estimatedCost) ?? 0),
                description: note.isEmpty ? nil : note,
                cookingTime: nil,
                color: color,
                customization: nil)
            
            appState.bulkUpdate { state in
                var dishes = state.userData
                    .activeMenu
                    .pages[0]
                    .dishes
                dishes.append(dish)
                state.userData.activeMenu.pages[0].dishes = dishes
            }
        }
        
        return true
    }
    
    func delete() {
        appState.bulkUpdate { [initialDish] state in
            var dishes = state.userData
                .activeMenu
                .pages[0]
                .dishes
            
            dishes.removeAll(where: { $0.id == initialDish?.id })
            state.userData.activeMenu.pages[0].dishes = dishes
        }
    }
    
    func validateFields() -> Bool {
        guard !name.isEmpty else { return false }
        guard code.count == 4 else { return false }
        guard Double(price) != nil else { return false }
        return true
    }
}
