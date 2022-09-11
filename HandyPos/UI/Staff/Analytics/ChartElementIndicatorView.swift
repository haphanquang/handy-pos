//
//  ChartElementIndicatorView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2021/12/30.
//

import Foundation
import SwiftUI

struct ChartElementIndicatorView: View {
    let firstColor: Color
    let secondColor: Color
    let name: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                Circle().fill(
                    LinearGradient(
                        gradient: Gradient(colors: [firstColor, secondColor]),
                        startPoint: .init(x: 0, y: 0.5),
                        endPoint: .init(x: 0, y: 1)
                    )
                ).frame(width: 8, height: 8)
                Text(LocalizedStringKey(name)).font(.caption).foregroundColor(.secondary)
                Spacer()
            }
        }
    }
}
