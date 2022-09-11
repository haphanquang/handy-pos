//
//  AnalyticsView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/25.
//

import Foundation
import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: AnalyticsViewModel
    @State var isShowingFilter = false
    @State var calendarId: UUID = UUID()
    
    var body: some View {
        VStack {
            if isShowingFilter {
                filteringView
            }
            Form {
                Section {
                    TodayAnalyticsView(viewModel: viewModel.todaySalesViewModel)
                    TodayFoodView(viewModel: viewModel.todayFoodViewModel)
                } header: {
                    Text(viewModel.dateTitle)
                } footer: {
                    Text("(*) Xin lưu ý: thống kê lợi nhuận không bao gồm Tuỳ chọn giá").italic()
                }
                
                if viewModel.isPeriodEmpty {
                    emptyview
                } else {
                    Section {
                        PeriodAnalyticsView(viewModel: viewModel.periodWeekViewModel)
                    } header: {
                        Text("7 ngày gần đây")
                    }
                    Section {
                        PeriodAnalyticsView(viewModel: viewModel.periodMonthViewModel)
                    } header: {
                        Text("30 ngày gần đây")
                    }
                }
                
            }.onAppear {
                viewModel.todaySalesViewModel.transform()
                viewModel.todayFoodViewModel.transform()
                viewModel.periodWeekViewModel.transform()
                viewModel.periodMonthViewModel.transform()
            }
        }
        .navigationTitle("Thống kê")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    withAnimation { isShowingFilter.toggle() }
                } label: {
                    Image(systemName: isShowingFilter ? "chevron.up" : "chevron.down")
                }
            }
        })
        .background(Color(uiColor: UIColor.systemGroupedBackground))
    }
    @ViewBuilder
    var filteringView: some View {
        VStack {
            DatePicker(
                "Ngày tạo đơn",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .id(calendarId)
            .onChange(of: viewModel.selectedDate) { newValue in
                calendarId = UUID()
            }
        }
        .padding(.top, 4)
        .padding(.horizontal)
    }
    @ViewBuilder
    var emptyview: some View {
        Section {
            VStack {
                Text("Không có đơn hàng")
            }
        }
    }
}

class AnalyticsViewModel: ObservableObject {
    let appState: AppState
    
    @Published var todaySalesViewModel: TodayAnalyticsViewModel
    @Published var todayFoodViewModel: TodayFoodViewModel
    
    var periodWeekViewModel: PeriodAnalyticsViewModel
    var periodMonthViewModel: PeriodAnalyticsViewModel
    
    @Published var selectedDate: Date = Date()
    @Published var dateTitle: LocalizedStringKey = LocalizedStringKey("Hôm nay")
    @Published var isPeriodEmpty = false
    
    init(appState: AppState) {
        self.appState = appState
        self.todaySalesViewModel = TodayAnalyticsViewModel(appState: appState, date: Date())
        self.todayFoodViewModel = TodayFoodViewModel(appState: appState, date: Date())
        self.periodWeekViewModel = PeriodAnalyticsViewModel(appState: appState)
        self.periodMonthViewModel = PeriodAnalyticsViewModel(appState: appState, style: .monthly)
        transform()
    }
    
    private func transform() {
        $selectedDate.map { [appState] date -> LocalizedStringKey in
            let dateFormater = DateFormatter()
            dateFormater.dateStyle = .medium
            dateFormater.locale = Locale(
                identifier: appState.value.userData.settings.userSelectedLanguage ?? Language.vietnam.rawValue
            )
            if Calendar.current.isDateInToday(date) {
                return LocalizedStringKey("Hôm nay")
            } else {
                return LocalizedStringKey(dateFormater.string(from: date))
            }
        }.assign(to: &$dateTitle)
        
        $selectedDate.map { [appState] in
            TodayAnalyticsViewModel(appState: appState, date: $0)
        }.assign(to: &$todaySalesViewModel)
        
        $selectedDate.map { [appState] in
            TodayFoodViewModel(appState: appState, date: $0)
        }.assign(to: &$todayFoodViewModel)
        
        periodWeekViewModel
            .$chartData
            .combineLatest(periodMonthViewModel.$chartData) {
                ($0 + $1).isEmpty
            }.assign(to: &$isPeriodEmpty)
    }
}
