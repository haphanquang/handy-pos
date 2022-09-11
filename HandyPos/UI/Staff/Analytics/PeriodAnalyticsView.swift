//
//  PeriodAnalyticsView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/31.
//

import Foundation
import SwiftUI
import SwiftUICharts

struct PeriodAnalyticsView: View {
    @ObservedObject var viewModel: PeriodAnalyticsViewModel
    
    var body: some View {
        VStack {
            if viewModel.style == .weekly {
                PeriodBarChart(data: viewModel.chartData)
                    .frame(minHeight: 250)
                    
            } else {
                PeriodLineChart(data: viewModel.chartData)
                    .frame(minHeight: 250)
            }
        }
    }
}

enum PeriodStyle {
    case weekly
    case monthly
}

class PeriodAnalyticsViewModel: ObservableObject {
    @Published var chartData: [(BusinessDate, sales: Double, profit: Double)] = []
    
    private(set) var appState: AppState
    private(set) var style: PeriodStyle
    
    init(appState: AppState, style: PeriodStyle = .weekly) {
        self.appState = appState
        self.style = style
        self.transform()
    }
    
    func transform() {
        var dates: [BusinessDate]
        if style == .weekly {
            dates = Date().startOfDay().recent7Days.map { BusinessDate(start: $0) }
        } else {
            dates = Date().startOfDay().recent30Days.map { BusinessDate(start: $0) }
        }
        
        appState.value.repositories
            .localRepository
            .fetchRecentOrders(start: dates[0].start)
            .map { orders in
                dates.map { bdate -> (BusinessDate, Double, Double) in
                    guard let dateOrders = orders[bdate] else { return (bdate, 0, 0) }
                    var sales: Double = 0, profit: Double = 0
                    for order in dateOrders where order.status == .finished {
                        sales += order.totalPrice.amount
                        profit += order.totalProfit.amount
                    }
                    return (bdate, sales, profit)
                }
            }
            .replaceError(with: [])
            .assign(to: &$chartData)
    }
    
    func isEmpty() -> Bool {
        return chartData.filter { $0.1 > 0 }.count > 0
    }
}
