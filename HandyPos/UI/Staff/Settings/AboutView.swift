//
//  AboutView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/01/14.
//

import Foundation
import SwiftUI

struct AboutView: View {
    @StateObject var viewModel = AboutViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Gởi yêu cầu")) {
                HeaderTextField("Tên", text: $viewModel.name)
                HeaderTextField("Email", text: $viewModel.email)
                HeaderTextField("Tiêu Đề", text: $viewModel.subject)
                HeaderTextEditor("Nội dung", text: $viewModel.message)
                
                LoadingButton(
                    action: viewModel.send,
                    title: "Gởi yêu cầu",
                    isLoading: $viewModel.isSending,
                    errorMessage: $viewModel.errorMessage
                ).foregroundColor(.green)
            }
            
            Section(header: Text("Thông tin liên lạc")) {
                Label("+81 0708 555 6689", systemImage: "phone.connection")
                Label("haphanquang@gmail.com", systemImage: "envelope.fill")
                Label("https://hapq.me", systemImage: "globe")
            }
        }
        .navigationTitle("Về chúng tôi")
    }
}

class AboutViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var subject = ""
    @Published var message = ""
    
    @Published var isSending = false
    @Published var errorMessage: String?
    
    private var cancelBag = CancelBag()
    
    init() {
        self.transform()
    }
    
    private func transform() {
        $errorMessage
            .reset(after: 2, on: RunLoop.main)
            .removeDuplicates()
            .assign(to: &$errorMessage)
    }
    
    func send() {
        guard !name.isEmpty, !email.isEmpty, !subject.isEmpty, !message.isEmpty else {
            return
        }
        let activityIndicator = ActivityIndicator()
        activityIndicator.loading.assign(to: &$isSending)
        
        let errorTracker = ErrorTracker()
        FirebaseRepository()
            .saveMessage(name: name, email: email, subject: subject, content: message)
            .trackActivity(activityIndicator)
            .trackError(errorTracker)
            .sink(receiveValue: { [weak self] message in
                self?.errorMessage = "đã gởi thành công"
                self?.clear()
            })
            .store(in: cancelBag)
    }
    
    private func clear() {
        name = ""
        email = ""
        subject = ""
        message = ""
    }
}

private struct ButtonBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 5).stroke(.gray, lineWidth: 0.5)
    }
}
