// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(member, names: named(state), named(send), named(subscript))
@attached(extension, conformances: ObservableObject)
public macro ViewModel() = #externalMacro(
    module: "ViewModelMacroMacros",
    type: "ViewModelMacro"
)
