//
//  CounterTests.swift
//  MacroTestTests
//
//  Created by 이택성 on 4/3/25.
//

import Testing
@testable import Counter

struct MacroTestTests {

    @Test func increaseExample() async throws {
        let viewModel = ViewModel()
        let initCount = viewModel.state.count
        viewModel.send(.increase)
        
        #expect(initCount+1 == viewModel.state.count)
    }

}
