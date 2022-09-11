//
//  SettingsRows.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/07/31.
//

import Foundation
import SwiftUI

struct SettingSegmentView<SelectionView, Item>: View where Item: Hashable, SelectionView: View {
    let title: String
    let selectionList: [Item]
    @Binding var selection: Item

    @ViewBuilder
    let itemBuilder: (Item) -> SelectionView

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
            Spacer()
            Picker("", selection: $selection) {
                ForEach(selectionList, id: \.hashValue) {
                    itemBuilder($0).tag($0)
                }
            }
            .frame(width: 60 * CGFloat(selectionList.count))
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}
