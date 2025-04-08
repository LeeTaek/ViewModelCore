import Combine
import Foundation
import UIKit
import ObjectiveC

@MainActor private var cancellablesKey: UInt8 = 0

@available(iOS 13.0, *)
// store(in:) 까지 같이 처리
public extension Publisher where Failure == Never {
    @MainActor
    func bind(
        on object: UIViewController,
        _ handler: @escaping (Output) -> Void) {
            self
                .receive(on: RunLoop.main)
                .sink(receiveValue: handler)
                .store(in: &object.cancellables)
        }
    
    // keypath 기반 bind
    func bind<Root: AnyObject> (
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on object: Root,
        storeIn cancellables: inout Set<AnyCancellable>) {
            self.receive(on: RunLoop.main)
                .sink { [weak object] value in
                    object?[keyPath: keyPath] = value
                }
                .store(in: &cancellables)
        }
}

@available(iOS 13.0, *)
final class CancellableBox: NSObject {
    var set = Set<AnyCancellable>()
}

@available(iOS 13.0, *)
public extension UIViewController {
    var cancellables: Set<AnyCancellable> {
        get {
            if let box = objc_getAssociatedObject(self, &cancellablesKey) as? CancellableBox {
                return box.set
            } else {
                let box = CancellableBox()
                objc_setAssociatedObject(self, &cancellablesKey, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return box.set
            }
        }
        set {
            let box = CancellableBox()
            box.set = newValue
            objc_setAssociatedObject(self, &cancellablesKey, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
