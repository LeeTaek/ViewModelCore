import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ViewModelMacroMacros)
import ViewModelMacroMacros
import ViewModelMacro

let testMacros: [String: Macro.Type] = [
    "ViewModel": ViewModelMacro.self,
]

@ViewModel
@dynamicMemberLookup
final class TestViewModel {
    struct State {
        var count = 42
    }

    enum Action {
        case noop
    }

    func reduce(state: inout State, action: Action) {}
}
#endif


final class ViewModelMacroTests: XCTestCase {
    
    func testMacro() throws {
#if canImport(ViewModelMacroMacros)
        assertMacroExpansion(
            """
            @ViewModel
            @dynamicMemberLookup
            final class MyViewModel {
                struct State {
                    var count = 0
                }
            
                enum Action {
                    case increment, decrement
                }
            
                func reduce(state: inout State, action: Action) {
                    switch action {
                    case .increment:
                        state.count += 1
                    case .decrement:
                        state.count -= 1
                    }
                }
            }
            """,
            expandedSource: """
            @dynamicMemberLookup
            final class MyViewModel {
                struct State {
                    var count = 0
                }
            
                enum Action {
                    case increment, decrement
                }
            
                func reduce(state: inout State, action: Action) {
                    switch action {
                    case .increment:
                        state.count += 1
                    case .decrement:
                        state.count -= 1
                    }
                }
            
                @Published private(set) var state = State()
            
                func send(_ action: Action) {
                    reduce(state: &state, action: action)
                }
            
                subscript <T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
                    state[keyPath: keyPath]
                }
            }
            
            extension MyViewModel: ObservableObject {
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macro 테스트는 host platform에서만 실행됩니다")
#endif
    }
    
    func testDynamicMemberLookup() throws {
#if canImport(ViewModelMacroMacros)
        let viewModel = TestViewModel()
        XCTAssertEqual(viewModel.count, viewModel.state.count)
#else
        throw XCTSkip("macro 테스트는 host platform에서만 실행됩니다")
        
#endif
    }
}
