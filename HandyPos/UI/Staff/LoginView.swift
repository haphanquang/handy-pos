//
//  LoginView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/17.
//

import Foundation
import SwiftUI
import Combine

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HeaderTextField("Username", text: $viewModel.username)
            HeaderTextField("Username", text: $viewModel.password)
            Button(action: viewModel.doLogin) {
                Text("Login")
                    .foregroundColor(.primary)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 8)
                    .background(
                        Capsule().fill(.red)
                    )
            }
        }
    }
}

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    
    init(appState: AppState) {
        
    }
    
    func doLogin() {
        
    }
}
