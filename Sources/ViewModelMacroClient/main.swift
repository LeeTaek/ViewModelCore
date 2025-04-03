import ViewModelMacro
import Foundation

@ViewModel
final class CounterViewModel {
    struct State {
        var count: Int = 0
    }
    
    enum Action {
        case increment
        case decrement
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
