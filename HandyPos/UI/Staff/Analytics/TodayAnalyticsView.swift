//
//  TodayAnalyticsView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/30.
//

import Foundation
import SwiftUICharts
import SwiftUI
    
struct TodayAnalyticsView: View {
    @ObservedObject var viewModel: TodayAnalyticsViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Tổng doanh thu")
                        Spacer()
                        (
                            Text("\(viewModel.todayFinishedOrderCount)/").foregroundColor(OrderStatus.finished.color)
                            + Text(LocalizedStringKey("\(viewModel.todayOrdersCount) đơn "))
                            + Text("hoàn tất").foregroundColor(OrderStatus.finished.color)
                        ).bold()
                    }
                    Text(viewModel.todaySales.money!).font(.title).bold()
                }
                
                Spacer()
            }
            if viewModel.todayProfit > 0 {
                HStack {
                    Text("Lợi nhuận ước tính")
                    Text(viewModel.todayProfit.money!)
                        .font(.body)
                        .bold()
                        .foregroundColor(OrderStatus.finished.color)
                    Spacer()
                }
            }
            compareChart
        }
        .padding(.vertical)
    }
    
    var compareChart: some View {
        HStack {
            RingsChart()
                .data([
                    ("trung bình tuần", viewModel.todayCompareToWeekAverage),
                    ("trung bình tháng", viewModel.todayCompareToMonthAverage)
                ])
                .chartStyle(
                    ChartStyle.init(
                        backgroundColor: .clear,
                        foregroundColor: [
                            ColorGradient(.orange.opacity(0.7), .orange),
                            ColorGradient(.yellow.opacity(0.8), .yellow)
                        ])
                )
                .frame(width: 110, height: 110)
            
            VStack(alignment: .leading) {
                ChartElementIndicatorView(
                    firstColor: .orange.opacity(0.7),
                    secondColor: .orange,
                    name: "So với TB tuần này \(viewModel.weekAverage.shortedMoney)")
                
                ChartElementIndicatorView(
                    firstColor: .yellow.opacity(0.8),
                    secondColor: .yellow,
                    name: "So với TB tháng này \(viewModel.monthAverage.shortedMoney)")
            }
            
            Spacer()
        }
    }
}

class TodayAnalyticsViewModel: ObservableObject {
    @Published var todaySales: Double = 0
    @Published var todayFinishedOrderCount: Int = 0
    @Published var todayOrdersCount: Int = 0
    @Published var todayProfit: Double = 0
    @Published var todayCompareToWeekAverage: Double = 0
    @Published var todayCompareToMonthAverage: Double = 0
    
    @Published var weekAverage: Double = 0
    @Published var monthAverage: Double = 0
    
    let appState: AppState
    let selectedDate: Date
    
    private var cancelBag = CancelBag()
    
    init(appState: AppState, date: Date) {
        self.appState = appState
        self.selectedDate = date
        self.transform()
    }
    
    func transform() {
        let orders = appState.value.repositories
            .localRepository
            .fetchOrders(on: selectedDate)
            .replaceError(with: [])
        
        let prices = orders
            .map {
                $0.filter { $0.status == .finished }
                .reduce((Price(amount: 0), Price(amount: 0)), { partialResult, order in
                    return (
                        partialResult.0.add(to: order.totalPrice),
                        partialResult.1.add(to: order.totalProfit)
                    )
                })
            }
        
        prices.map { $0.0.amount }.assign(to: &$todaySales)
        prices.map { $0.1.amount }.assign(to: &$todayProfit)
        orders.map { $0.count }.assign(to: &$todayOrdersCount)
        orders.map { $0.filter { $0.status == .finished }.count }
            .assign(to: &$todayFinishedOrderCount)
        
        transformWeekAverage()
        transformMonthAverage()
    }
    
    private func transformWeekAverage() {
        let week = Date()
            .startOfDay()
            .recent7Days
            .dropLast()
            .map { BusinessDate(start: $0) }
        
        appState.value.repositories.localRepository
            .fetchRecentOrders(start: week[0].start)
            .map { orders in
                week.compactMap {
                    orders[$0]?.filter {
                        $0.status == .finished
                    }.reduce(0, { $0 + $1.totalPrice.amount })
                }.reduce(0, +) / Double(week.count)
            }
            .replaceError(with: 0)
            .assign(to: &$weekAverage)
        
        $todaySales.combineLatest($weekAverage) { min($0 / $1 * 100, 100) }
            .assign(to: &$todayCompareToWeekAverage)
    }
    
    private func transformMonthAverage() {
        let month = Date()
            .startOfDay()
            .recent30Days
            .dropLast()
            .map { BusinessDate(start: $0) }
        
        appState.value.repositories
            .localRepository
            .fetchRecentOrders(start: month[0].start)
            .map { orders in
                month.compactMap {
                    orders[$0]?.filter { $0.status == .finished }
                        .reduce(0, { $0 + $1.totalPrice.amount })
                }.reduce(0, +) / Double(month.count)
            }
            .replaceError(with: 0)
            .assign(to: &$monthAverage)
        
        $todaySales.combineLatest($monthAverage) { min($0 / $1 * 100, 100) }
            .assign(to: &$todayCompareToMonthAverage)
    }
    
    private func recentWeekdays() -> [BusinessDate] {
        let today = Date().startOfDay()
        return ((-7)...(-1)).map { val in
            let day = Calendar.current.date(byAdding: DateComponents(day: val), to: today)!
            return BusinessDate(start: day, end: nil)
        }
    }
}
