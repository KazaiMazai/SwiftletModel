//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 30/03/2025.
//

import Foundation

public struct Descending<T: Comparable>: Comparable, Sendable where T: Sendable {
    public let value: T

    public static func < (lhs: Descending<T>, rhs: Descending<T>) -> Bool {
        return lhs.value > rhs.value
    }
}

public extension Comparable where Self: Sendable {
    var desc: Descending<Self> { Descending(value: self) }
}
