import Combine
import Foundation
import UIKit
import ObjectiveC

@MainActor private var cancellablesKey: UInt8 = 0

@available(iOS 13.0, *)
public extension Publisher where Failure == Never {
    // store(in:) 까지 같이 처리
    func bind(
        storeIn cancellables: inout Set<AnyCancellable>,
        _ handler: @escaping (Output) -> Void
    ) {
        self
            .receive(on: RunLoop.main)
            .sink(receiveValue: handler)
            .store(in: &cancellables)
    }
    
    //
    func bind<Root: AnyObject> (
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on object: Root,
        storeIn cancellables: inout Set<AnyCancellable>
    ) {
        self.receive(on: RunLoop.main)
            .sink { [weak object] value in
                object?[keyPath: keyPath] = value
            }
            .store(in: &cancellables)
    }
}

@available(iOS 13.0, *)
public extension UIViewController {
    var cancellables: Set<AnyCancellable> {
        get {
            if let stored = objc_getAssociatedObject(self, &cancellablesKey) as? Set<AnyCancellable> {
                return stored
            } else {
                let initial: Set<AnyCancellable> = []
                objc_setAssociatedObject(self, &cancellablesKey, initial, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return initial
            }
        }
        set {
            objc_setAssociatedObject(self, &cancellablesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
