//
//  MenuSettingsView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/31.
//

import Foundation
import SwiftUI

struct MenuSettingsView: View {
    @ObservedObject var viewModel: MenuSettingsViewModel
    
    @State private var isPresentingNewView = false
    
    var body: some View {
        List {
            ForEach(viewModel.dishes, id: \.self) { dish in
                NavigationLink {
                    NewMenuView(viewModel: NewMenuViewModel(appState: viewModel.appState, dish: dish))
                } label: {
                    MenuDishRowView(dish: dish).padding(.vertical, 2)
                }
            }
            .onMove(perform: viewModel.move(from:to:))
            .onDelete(perform: viewModel.delete(at:))
        }.toolbar {
            HStack {
                EditButton()
                Button(action: presentNewScreen) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingNewView, onDismiss: nil) {
            NavigationView {
                NewMenuView(viewModel: NewMenuViewModel(appState: viewModel.appState, dish: nil))
            }.navigationViewStyle(.stack)
        }
        .navigationTitle("Menu bán hàng")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func presentNewScreen() {
        isPresentingNewView = true
    }
}

class MenuSettingsViewModel: ObservableObject {
    @Published var dishes: [Dish]
    
    let appState: AppState
    private var cancelBag = CancelBag()
    
    init(appState: AppState) {
        self.appState = appState
        self.dishes = appState.value.userData.activeMenu.dishes
        self.transform()
    }
    
    private func transform() {
        self.appState
            .publisher(for: \.userData.activeMenu.dishes)
            .assign(to: &$dishes)
        
        $dishes
            .removeDuplicates()
            .sink { [appState] dishes in
                appState.bulkUpdate { [dishes] in
                    // there's only one page currently
                    var page = $0.userData.activeMenu.pages[0]
                    page.dishes = dishes
                    $0.userData.activeMenu.pages = [page]
                }
            }.store(in: cancelBag)
        
        self.appState
            .publisher(for: \.userData.activeMenu)
            .removeDuplicates()
            .combineLatest(appState.publisher(for: \.repositories.localRepository)) { menu, repository in
                repository.updateMenu(menu)
            }
            .switchToLatest()
            .replaceError(with: false)
            .sink { _ in }
            .store(in: cancelBag)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        dishes.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at indexes: IndexSet) {
        dishes.remove(atOffsets: indexes)
    }
}

struct MenuDishRowView: View {
    let dish: Dish
    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                Text(dish.code)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(dish.color ?? .secondary))
                
                VStack(alignment: .leading) {
                    Text(dish.name)
                        .foregroundColor(.primary)
                        .font(.body.leading(.tight))
                        .lineSpacing(3)
                    if let extra = dish.description {
                        Text(extra).font(.caption).foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(dish.price.formatted)
                    .bold()
                    .monospacedDigit()
            }
        }
    }
}
