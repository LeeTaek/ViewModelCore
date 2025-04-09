//
//  ViewModel.swift
//  MacroTest
//
//  Created by 이택성 on 4/3/25.
//

import Foundation
import ViewModelMacro

@ViewModel
final class ViewModel {
    struct State {
        var count: Int = 0
        var text: String = ""
        var datasourceItem: [Int] = { Array(0..<40) }()
    }
    
    enum Action {
        case increase
        case decrease
        case inputTextfield(String)
        case increaseDatasourceItems
        case decreaseDatasourceItems
        case reset
    }
    
    func reduce(state: inout State, action: Action) {
        switch action {
        case .increase:
            state.count += 1
        case .decrease:
            state.count -= 1
        case .inputTextfield(let text):
            state.text = text
        case .reset:
            state.count = 0
            state.text = ""
        case .increaseDatasourceItems:
            let items = state.datasourceItem
            if items.isEmpty {
                state.datasourceItem = [0]
            } else {
                state.datasourceItem = items + [items.count]
            }
        case .decreaseDatasourceItems:
            let items = state.datasourceItem
            if !items.isEmpty {
                state.datasourceItem = items.dropLast()
            }
        }
    }
}
