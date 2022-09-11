//
//  SettingsView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/27.
//

import Foundation
import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State var isPresentingWarning: Bool = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        Form {
            salesSection
            aboutAppSection
            backupSection
            resetSection
        }
        .navigationTitle("Cài đặt")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    private func sync() {
        viewModel.sync()
    }
    private func reset() {
        viewModel.resetDatabase()
    }
}

extension SettingsView {
    @ViewBuilder
    var salesSection: some View {
        Section(header: Text("Bán hàng")) {
            NavigationLink {
                MenuSettingsView(viewModel: viewModel.menuSettingsViewModel)
            } label: {
                Text("Menu")
            }
            NavigationLink {
                StoreSettingsView(viewModel: viewModel.storeSettingsViewModel)
            } label: {
                Text("Thông tin Cửa hàng")
            }
        }
    }
    
    @ViewBuilder
    var aboutAppSection: some View {
        Section(header: Text("Về ứng dụng")) {
            NavigationLink {
                AboutView()
            } label: {
                Text("Liên hệ")
            }
            
            HStack {
                Text("Phiên bản ứng dụng")
                Spacer()
                Text("\(appVersion ?? "không rõ")").bold()
            }
            
            SettingSegmentView(
                title: "Ngôn ngữ",
                selectionList: viewModel.allLanguages,
                selection: $viewModel.selectedLanguage
            ) {
                Text($0.title)
            }
        }
    }
    
    @ViewBuilder
    var backupSection: some View {
        Section {
            HStack {
                LoadingButton(
                    action: sync,
                    title: "Sao lưu & đồng bộ",
                    isLoading: $viewModel.isSaving,
                    errorMessage: $viewModel.savingErrorMessage)
                Image(systemName: "tray.and.arrow.down")
            }
            
            (
                Text("Dữ liệu sao lưu có thể truy cập bằng ứng dụng Files của iPhone. ").font(.caption).italic()
                + Text("Vào ").font(.caption).italic()
                + Text("Files -> Browse -> On My iPhone -> hPOS").font(.caption).bold()
                + Text(" và copy thư mục Database").font(.caption).italic()
            )
        }
    }
    
    @ViewBuilder
    var resetSection: some View {
        Section {
            Button("Xoá toàn bộ dữ liệu và trả về mặc định", action: { isPresentingWarning = true })
                .foregroundColor(.red)
                .alert("Cẩn thận", isPresented: $isPresentingWarning) {
                    Button(role: .destructive) {
                        self.reset()
                    } label: {
                        Text("Xoá liền")
                    }
                } message: {
                    Text("Toàn bộ dữ liệu bán hàng, kể cả menu, sẽ bị xoá và trả về mặc định")
                }
        }
    }
}

