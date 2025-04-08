//
//  CounterTests.swift
//  MacroTestTests
//
//  Created by 이택성 on 4/3/25.
//

import Testing
@testable import Counter

final class MacroTestTests {
    var viewModel: ViewModel
    
    init() {
        self.viewModel = ViewModel()
    }
    
    deinit {
        viewModel.send(.reset)
    }

    @Test func increaseExample() async throws {
        let initCount = viewModel.state.count
        viewModel.send(.increase)
        
        #expect(initCount+1 == viewModel.state.count)
    }

    
    @Test func inputTextfield() async throws {
        let text = "안녕하세요"
        viewModel.send(.inputTextfield("안녕하세요"))
        
        #expect(text == viewModel.state.text)
    }
}
