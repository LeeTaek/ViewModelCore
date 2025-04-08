import ViewModelMacro
import Foundation

@ViewModel
final class CounterViewModel {
    typealias Send = (@Sendable (Action) async -> Void)
    typealias Effect = (@Sendable (Send) async -> Void)
    
    struct State {
        var count: Int = 0
    }
    
    enum Action {
        case increment
        case decrement
        case increaseTen
    }
    
    func reduce(state: inout State, action: Action) -> Effect? {
        switch action {
        case .increment:
            state.count += 1
        case .decrement:
            state.count -= 1
        case .increaseTen:
            state.count += 10
        }
        return nil
    }
    
}
