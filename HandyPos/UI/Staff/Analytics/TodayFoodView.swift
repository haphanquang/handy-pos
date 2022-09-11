//
//  TodayFoodView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/30.
//

import Foundation
import SwiftUI
import SwiftUICharts
import OrderedCollections

private enum ChartType: Int, CaseIterable {
    case sales = 1
    case product = 2
    case profit = 3
    
    var name: LocalizedStringKey {
        switch self {
        case .sales: return LocalizedStringKey("Doanh thu")
        case .product: return LocalizedStringKey("Số lượng")
        case .profit: return LocalizedStringKey("Lợi nhuận ước tính")
        }
    }
}

struct TodayFoodView: View {
    private let columns = Array(
        repeating: GridItem(
            .flexible(),
            spacing: 6,
            alignment: .center
        ),
        count: 2)
    @ObservedObject var viewModel: TodayFoodViewModel
    @State private var chartType: ChartType = .sales
    
    var body: some View {
        if viewModel.todayChartInfo.isEmpty {
            emptyView.padding()
        } else {
            VStack(alignment: .leading) {
                HStack {
                    Text("Tỷ lệ theo món")
                    Spacer()
                    Picker(">", selection: $chartType) {
                        ForEach(ChartType.allCases.reversed(), id: \.self) {
                            Text($0.name).tag($0)
                        }
                    }.pickerStyle(.menu)
                }
                
                HStack {
                    switch chartType {
                    case .sales: salesChart
                    case .profit: profitChart
                    case .product: productChart
                    }
                }
            }.padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private var salesChart: some View {
        TodayFoodPieChart(
            data: viewModel.todayChartInfo.map { ($0.color ?? .blue, $0.name, $0.value) },
            label: "doanh thu"
        ).frame(height: 250)
    }
    
    @ViewBuilder
    private var productChart: some View {
        TodayFoodPieChart(
            data: viewModel.todayChartInfo.map { ($0.color ?? .blue, $0.name, Double($0.quantity)) },
            label: "số lượng"
        ).frame(height: 250)
    }
    @ViewBuilder
    private var profitChart: some View {
        TodayFoodPieChart(
            data: viewModel.todayChartInfo.map { ($0.color ?? .blue, $0.name, Double($0.profit ?? 0)) },
            label: "lợi nhuận ước tính"
        ).frame(height: 250)
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack {
            Text("Không có đơn hàng")
        }
    }
}

class TodayFoodViewModel: ObservableObject {
    @Published var todayChartInfo: [TodayChartData]
    
    let appState: AppState
    let date: Date
    
    init(appState: AppState, date: Date) {
        self.appState = appState
        self.date = date
        self.todayChartInfo = appState.value.userData.todayOrders.chartInfo
        self.transform()
    }
    
    func transform() {
        appState.value.repositories.localRepository
            .fetchOrders(on: date)
            .replaceError(with: [])
            .map { $0.chartInfo }
            .assign(to: &$todayChartInfo)
    }
}

struct TodayChartData: Hashable {
    let name: String
    var color: Color?
    var value: Double
    var quantity: Int
    var profit: Double?
}

private extension Array where Element == Order {
    var allSalesItems: OrderedDictionary<Dish, Int> {
        var merged = OrderedDictionary<Dish, Int>()
        for order in self {
            merged.merge(order.mergedItems, uniquingKeysWith: { $0 + $1 })
        }
        return merged
    }
    
    var chartInfo: [TodayChartData] {
        let items = allSalesItems
        var result = [TodayChartData]()
        
        var customFood = TodayChartData(
            name: Dish.customPriceCode,
            color: nil,
            value: 0,
            quantity: 0,
            profit: nil
        )
        
        for (dish, quantity) in items {
            let name = dish.code
            let price = dish.price.multiply(by: quantity).amount
            let profit = dish.profit?.multiply(by: quantity).amount
            
            if name == Dish.customPriceCode {
                customFood.value += price
                customFood.quantity += quantity
                if let prof = profit {
                    customFood.profit = (customFood.profit ?? 0) + prof
                }
            } else {
                result.append(
                    TodayChartData(
                        name: name,
                        color: dish.color,
                        value: price,
                        quantity: quantity,
                        profit: profit
                    )
                )
            }
        }
        
        if customFood.value > 0 {
            result.append(customFood)
        }
        
        return result
    }
}
