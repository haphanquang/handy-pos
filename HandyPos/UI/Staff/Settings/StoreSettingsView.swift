//
//  StoreSettingsView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/04/16.
//

import Foundation
import SwiftUI
import RealmSwift

struct StoreSettingsView: View {
    @ObservedObject var viewModel: StoreSettingsViewModel
    
    var body: some View {
        Form {
            Section {
                HeaderTextField("Tên cửa hàng", text: $viewModel.storeName)
                    .showsClearWhileEditing($viewModel.storeName)
                HeaderTextField("Số điện thoại", text: $viewModel.phoneNumber)
                    .showsClearWhileEditing($viewModel.phoneNumber)
                    .keyboardType(.numbersAndPunctuation)
                HeaderTextField("Địa chỉ", text: $viewModel.address1)
                    .showsClearWhileEditing($viewModel.address1)
                HeaderTextField("Địa chỉ mở rộng", text: $viewModel.address2)
                    .showsClearWhileEditing($viewModel.address2)
                HeaderTextField("Mã bưu chính", text: $viewModel.zip)
                    .showsClearWhileEditing($viewModel.zip)
                    .keyboardType(.numbersAndPunctuation)
            }
            
            Section {
                HeaderTextField("Lời chúc", text: $viewModel.wish)
                    .showsClearWhileEditing($viewModel.wish)
            }
            
            Section {
                LoadingButton(
                    action: viewModel.save,
                    title: "Cập nhật",
                    isLoading: $viewModel.isSaving,
                    errorMessage: $viewModel.savingErrorMessage)
            }
        }.navigationTitle("Thông tin Cửa hàng")
        .navigationBarTitleDisplayMode(.inline)
    }
}

class StoreSettingsViewModel: ObservableObject {
    @Published var storeName: String = ""
    @Published var phoneNumber: String = ""
    @Published var address1: String = ""
    @Published var address2: String = ""
    @Published var zip: String = ""
    @Published var wish: String = ""
    
    @Published var isSaving = false
    @Published var savingErrorMessage: String?
    
    private let appState: AppState
    private var cancelBag = CancelBag()
    
    init(appState: AppState) {
        self.appState = appState
        self.transform()
    }
    
    private func transform() {
        appState
            .publisher(for: \.userData.currentStore)
            .removeDuplicates()
            .combineLatest(appState.publisher(for: \.repositories.localRepository)) { store, repository in
                repository.updateStore(store)
            }
            .switchToLatest()
            .replaceError(with: false)
            .sink { _ in }
            .store(in: cancelBag)
        
        let store = appState.publisher(for: \.userData.currentStore)
        store.map(\.name).assign(to: &$storeName)
        store.map(\.phoneNumber).replaceNil(with: "").assign(to: &$phoneNumber)
        store.map(\.address1).replaceNil(with: "").assign(to: &$address1)
        store.map(\.address2).replaceNil(with: "").assign(to: &$address2)
        store.map(\.zipCode).replaceNil(with: "").assign(to: &$zip)
        store.map(\.billNote).replaceNil(with: "").assign(to: &$wish)
        
        $savingErrorMessage
            .reset(after: 2, on: RunLoop.main)
            .removeDuplicates()
            .assign(to: &$savingErrorMessage)
            
    }
    
    func save() {
        isSaving = true
        appState.bulkUpdate { [storeName, phoneNumber, address1, address2, zip, wish] in
            $0.userData.currentStore.name = storeName
            $0.userData.currentStore.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
            $0.userData.currentStore.address1 = address1.isEmpty ? nil : address1
            $0.userData.currentStore.address2 = address2.isEmpty ? nil : address2
            $0.userData.currentStore.zipCode = zip.isEmpty ? nil : zip
            $0.userData.currentStore.billNote = wish.isEmpty ? nil : wish
            isSaving = false
        }
        savingErrorMessage = "Đã cập nhật"
    }
}
