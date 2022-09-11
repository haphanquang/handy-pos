//
//  ChartsWrapper.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/01/04.
//

import Foundation
import Charts
import SwiftUI

struct PeriodBarChart: UIViewRepresentable {
    var data: [(BusinessDate, sales: Double, profit: Double)]
    
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        chart.rightAxis.enabled = false
        chart.scaleYEnabled = false
        chart.scaleXEnabled = false
        
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map { $0.0.symbol })
        chart.leftAxis.valueFormatter = CustomAxisFormatter()
        
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        uiView.data = preprareDataForChart()
        uiView.barData?.setValueFormatter(CustomValueFormatter())
    }
    
    private func preprareDataForChart() -> BarChartData {
        var salesEntries = [BarChartDataEntry]()
        var profitEntries = [BarChartDataEntry]()
        
        for (index, dayData) in data.enumerated() {
            salesEntries.append(BarChartDataEntry(x: Double(index), y: dayData.sales))
            profitEntries.append(BarChartDataEntry(x: Double(index), y: dayData.profit))
        }
        
        let salesDataSet = BarChartDataSet(entries: salesEntries)
        salesDataSet.label = "Tổng doanh thu"
        salesDataSet.setColor(.systemOrange)
        
        let profitDataSet = BarChartDataSet(entries: profitEntries)
        profitDataSet.label = "Lợi nhuận ước tính"
        profitDataSet.setColor(.systemBlue)
        profitDataSet.valueTextColor = .white
        
        let data = BarChartData()
        data.addDataSet(salesDataSet)
        data.addDataSet(profitDataSet)
        return data
    }
}

struct PeriodLineChart: UIViewRepresentable {
    var data: [(BusinessDate, sales: Double, profit: Double)]
    
    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.rightAxis.enabled = false

        chart.dragEnabled = true
        chart.scaleYEnabled = false
        
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map { $0.0.day })
        
        chart.leftAxis.valueFormatter = CustomAxisFormatter()
        chart.leftAxis.axisMinimum = 0.0
        chart.leftAxis.drawZeroLineEnabled = false
        chart.leftAxis.drawGridLinesEnabled = true
        chart.leftAxis.drawZeroLineEnabled = false
        chart.leftAxis.granularityEnabled = true
        
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = preprareDataForChart()
        uiView.lineData?.setValueFormatter(CustomValueFormatter())
    }
    
    private func preprareDataForChart() -> LineChartData {
        var salesEntries = [ChartDataEntry]()
        var profitEntries = [ChartDataEntry]()
        
        for (index, dayData) in data.enumerated() {
            salesEntries.append(ChartDataEntry(x: Double(index), y: dayData.sales))
            profitEntries.append(ChartDataEntry(x: Double(index), y: dayData.profit))
        }
        
        let salesDataSet = LineChartDataSet(entries: salesEntries)
        salesDataSet.label = "Tổng doanh thu"
        salesDataSet.setColor(.systemOrange)
        salesDataSet.drawCirclesEnabled = false
        salesDataSet.fillAlpha = 1
        salesDataSet.fillColor = .systemOrange
        salesDataSet.drawFilledEnabled = true
        salesDataSet.mode = .cubicBezier
        salesDataSet.drawValuesEnabled = false
        
        let profitDataSet = LineChartDataSet(entries: profitEntries)
        profitDataSet.label = "Lợi nhuận ước tính"
        profitDataSet.setColor(.systemBlue)
        profitDataSet.drawCirclesEnabled = false
        profitDataSet.fillAlpha = 1
        profitDataSet.fillColor = .systemBlue
        profitDataSet.drawFilledEnabled = true
        profitDataSet.mode = .cubicBezier
        profitDataSet.drawValuesEnabled = false
        
        let data = LineChartData()
        data.addDataSet(salesDataSet)
        data.addDataSet(profitDataSet)
        return data
    }
}

struct TodayFoodPieChart: UIViewRepresentable {
    var data: [(Color, String, Double)]
    var label: String
    
    func makeUIView(context: Context) -> PieChartView {
        let chart = PieChartView()
        chart.legend.horizontalAlignment = .center
        return chart
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        uiView.data = preprareDataForChart()
        uiView.drawEntryLabelsEnabled = false
    }
    
    private func preprareDataForChart() -> PieChartData {
        let entries = data.map { (color, label, value) -> PieChartDataEntry in
            return PieChartDataEntry(value: value, label: label)
        }
        let dataSet = PieChartDataSet(entries: entries)
        dataSet.colors = data.map { NSUIColor($0.0) }
        dataSet.label = ""
        dataSet.valueFont = .boldSystemFont(ofSize: 9)
        let data = PieChartData()
        data.addDataSet(dataSet)
        data.setValueFormatter(CustomPieFormatter())
        return data
    }
}

private class CustomAxisFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return value.shortedMoney
    }
}
private class CustomValueFormatter: IValueFormatter {
    func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int, viewPortHandler: ViewPortHandler?
    ) -> String {
        if value < 1 { return "" }
        return value.shortedMoney
    }
}

private class CustomPieFormatter: IValueFormatter {
    func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?
    ) -> String {
        return value.shortedMoney
    }
}
