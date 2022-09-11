//
//  HomeView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/27.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: .zero) {
            tabContentView
            Divider()
            tabBar
        }
    }
    
    @ViewBuilder
    private var tabContentView: some View {
        TabView(selection: $viewModel.selectedTab) {
            VStack {
                Picker("", selection: $viewModel.inputTab) {
                    ForEach(InputTab.allCases) { inputType in
                        Text(inputType.name).tag(inputType)
                    }
                }.pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                TabView(selection: $viewModel.inputTab) {
                    GoodsGridView(viewModel: viewModel.goodsVM).tag(InputTab.menu)
                    NumPadView(viewModel: viewModel.numpadVM).tag(InputTab.keypad)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
            }
            .tag(viewModel.tabs[0])
            
            NavigationView {
                OrderListView(viewModel: viewModel.orderListVM)
            }.navigationViewStyle(.stack)
            .tag(viewModel.tabs[1])
            
            NavigationView {
                AnalyticsView(viewModel: viewModel.analyticsVM)
            }.navigationViewStyle(.stack)
            .tag(viewModel.tabs[2])
            
            NavigationView {
                SettingsView(viewModel: viewModel.settingsVM)
            }.navigationViewStyle(.stack)
            .tag(viewModel.tabs[3])
        }.onAppear {
            UITabBar.appearance().isHidden = true
        }
    }
    
    @ViewBuilder
    private var tabBar: some View {
        TabbBar(tabs: viewModel.tabs, selected: $viewModel.selectedTab)
    }
}

class HomeViewModel: ObservableObject {
    @Published var tabs: [TabbItem] = TabIndex.allCases.map { $0.makeTabbbItem() }
    @Published var selectedTab = TabIndex.quickSell.makeTabbbItem()
    @Published var inputTab: InputTab
    
    var goodsVM: GoodsGridViewModel
    var orderListVM: OrderListViewModel
    var analyticsVM: AnalyticsViewModel
    var settingsVM: SettingsViewModel
    var numpadVM: NumPadViewModel
    
    private(set) var appState: AppState
    private var cancelBag = CancelBag()
    
    init(appState: AppState) {
        self.appState = appState
        
        self.goodsVM = GoodsGridViewModel(appState: appState)
        self.orderListVM = OrderListViewModel(appState: appState)
        self.analyticsVM = AnalyticsViewModel(appState: appState)
        self.settingsVM = SettingsViewModel(appState: appState)
        self.numpadVM = NumPadViewModel(appState: appState)
        
        self.inputTab = appState.value.userData.settings.defaultMenuTab
        self.transform()
    }
    
    private func transform() {
        self.appState.publisher(for: \.userData.todayOrders)
            .map { $0.count }
            .combineLatest($tabs) { ordersCount, tabs in
                var orderTabItem = tabs[1]
                orderTabItem.badge = ordersCount
                var newTabs = tabs
                newTabs[1] = orderTabItem
                return newTabs
            }.assign(to: &$tabs)
        
        $inputTab
            .removeDuplicates()
            .sink { [appState] tab in
                appState.bulkUpdate { $0.userData.settings.defaultMenuTab = tab }
            }.store(in: cancelBag)
    }
}

enum TabIndex: Int, CaseIterable {
    case quickSell = 0, orders, analytics, settings
    var title: String {
        switch self {
        case .quickSell: return "Bán nhanh"
        case .orders: return "Đơn hàng"
        case .analytics: return "Thống kê"
        case .settings: return "Cài đặt"
        }
    }
    
    var imageName: String {
        switch self {
        case .quickSell: return "dollarsign.circle.fill"
        case .orders: return "checklist"
        case .analytics: return "chart.line.uptrend.xyaxis"
        case .settings: return "gear"
        }
    }
    
    var rotationType: TabbItem.RotateType {
        switch self {
        case .analytics, .orders: return .threeD
        default: return .normal
        }
    }
    
    func makeTabbbItem() -> TabbItem {
        return TabbItem(title: self.title, imageName: self.imageName, rotationType: self.rotationType)
    }
}

enum InputTab: String, CaseIterable, Identifiable, Codable {
    case menu
    case keypad

    var id: String { self.rawValue }
    var name: LocalizedStringKey {
        switch self {
        case .keypad: return LocalizedStringKey("Phím số")
        case .menu: return LocalizedStringKey("Chọn món")
        }
    }
}
