//
//  UIComponentPublisher.swift
//  BindingSupport
//
//  Created by 이택성 on 4/4/25.
//
import UIKit
import Combine

@available(iOS 13.0, *)
public extension UIControl {
    /// Control Publisher
    func controlPublisher(for event: UIControl.Event) -> UIControl.EventPublisher {
        return UIControl.EventPublisher(control: self, event: event)
    }
    
    /// Event Publisher
    @MainActor
    struct EventPublisher: @preconcurrency Publisher {
        public typealias Output = UIControl
        public typealias Failure = Never
        
        private weak var control: Output?
        private let event: UIControl.Event
        
        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Output {
            guard let control else {
                subscriber.receive(completion: .finished)
                return
            }

            let subscription = EventSubscription(
                subscriber: subscriber,
                control: control,
                event: event
            )
            subscriber.receive(subscription: subscription)
        }
    }
    
    /// Event Subscription
    @MainActor
    private class EventSubscription<S: Subscriber>: @preconcurrency Subscription, CustomCombineIdentifierConvertible
    where S.Input == UIControl {
        private let subscriber: S?
        private weak var control: UIControl?
        private let event: UIControl.Event
        
        init(subscriber: S, control: UIControl?, event: UIControl.Event) {
            self.control = control
            self.subscriber = subscriber
            self.event = event
            self.control?.addTarget(self, action: #selector(handleEvent), for: event)
        }
        
        @objc private func handleEvent(_ sender: UIControl) {
            _ = self.subscriber?.receive(sender)
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            self.control?.removeTarget(self, action: #selector(handleEvent), for: self.event)
            self.control = nil
        }
    
    }
}

@available(iOS 13.0, *)
public extension UITextField {
    /// 텍스트 필드 입력
    var textPublisher: AnyPublisher<String?, Never> {
        controlPublisher(for: .editingChanged)
            .compactMap { $0 as? UITextField }
            .map { $0.text }
            .eraseToAnyPublisher()
    }
    
    /// 텍스트 필드 입력 Debounce
    var textDebouncePublisher: AnyPublisher<String?, Never> {
        textPublisher.debounce(for: 0.1, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    /// 텍스트 필드 편집 종료  Publisher
    var didEndEditingPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .editingDidEnd)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

@available(iOS 13.0, *)
public extension UIButton {
    /// 버튼 touchUpInside 처리
    var tapPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .touchUpInside)
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    /// 버튼 touchUpInside Debounce
    var tapDebouncePublisher: AnyPublisher<Void, Never> {
        tapPublisher.debounce(for: 0.1, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

@available(iOS 13.0, *)
public extension UISwitch {
    /// valueChanged 처리
    var statePublisher: AnyPublisher<Bool, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UISwitch }
            .map { $0.isOn }
            .eraseToAnyPublisher()
    }
}

@available(iOS 13.0, *)
public extension UIStepper {
    /// valueChanged 처리
    var valuePublisher: AnyPublisher<Double, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UIStepper }
            .map { $0.value }
            .eraseToAnyPublisher()
    }
}

@available(iOS 13.0, *)
public extension UISegmentedControl {
    /// valueChanged 처리
    var selectionPublisher: AnyPublisher<Int, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UISegmentedControl }
            .map { $0.selectedSegmentIndex }
            .eraseToAnyPublisher()
    }
}

@available(iOS 13.0, *)
public extension UISlider {
    /// valueChanged 처리
    var valuePublisher: AnyPublisher<Float, Never> {
        controlPublisher(for: .valueChanged)
            .compactMap { $0 as? UISlider }
            .map { $0.value }
            .eraseToAnyPublisher()
    }
}
