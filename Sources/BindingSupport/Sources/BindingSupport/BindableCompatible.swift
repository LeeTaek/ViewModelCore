//
//  BindableCompatible.swift
//  BindingSupport
//
//  Created by 이택성 on 4/4/25.
//

import UIKit
import Combine

@available(iOS 13.0, *)
public protocol BindableCompatible: AnyObject {}

@available(iOS 13.0, *)
public extension BindableCompatible {
    func bind<Value>(
        _ publisher: AnyPublisher<Value, Never>,
        to keyPath: ReferenceWritableKeyPath<Self, Value>,
        storeIn cancellables: inout Set<AnyCancellable>
    ) {
        publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?[keyPath: keyPath] = value
            }
            .store(in: &cancellables)
    }
}

@available(iOS 13.0, *)
extension UILabel: BindableCompatible { }

@available(iOS 13.0, *)
extension UIButton: BindableCompatible { }

@available(iOS 13.0, *)
extension UISwitch: BindableCompatible { }
