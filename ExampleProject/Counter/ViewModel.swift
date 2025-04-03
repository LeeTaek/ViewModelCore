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
    }
    
    enum Action {
        case increase
        case decrease
    }
    
    func reduce(state: inout State, action: Action) {
        switch action {
        case .increase:
            state.count += 1
        case .decrease:
            state.count -= 1
        }
    }
}
