//
//  File.swift
//
//
//  Created by Serge Kazakov on 02/03/2024.
//

import Foundation

public struct MergeStrategy<T>: Sendable {
    let handler: @Sendable (_ old: T, _ new: T) -> T

    public init(merge: @Sendable @escaping (T, T) -> T) {
        self.handler = merge
    }
    
    public func merge(_ existing: T, new: T) -> T {
        handler(existing, new)
    }
}

public extension MergeStrategy {
    static var replace: MergeStrategy<T> {
        MergeStrategy(merge: { _, new in new })
    }
}

public extension MergeStrategy {
    init(_ strategies: MergeStrategy<T>...) {
        handler = { old, new in
            strategies.reduce(new) { result, strategy in
                strategy.merge(old, new: result)
            }
        }
    }

    static func lastWriteWins<V: Comparable>(
        _ strategies: MergeStrategy<T>...,
        comparedBy keyPath: @Sendable @escaping @autoclosure () -> KeyPath<T, V>
    ) -> MergeStrategy<T> {

        lastWriteWins(strategies, comparedBy: keyPath())
    }

    static func lastWriteWins(
        _ strategies: MergeStrategy<T>...) -> MergeStrategy<T>
    where T: Comparable {

        lastWriteWins(strategies, comparedBy: \.self)
    }

    static func lastWriteWins<V: Comparable>(
        _ strategies: [MergeStrategy<T>],
        comparedBy keyPath: @Sendable @escaping @autoclosure () -> KeyPath<T, V>
    ) -> MergeStrategy<T> {

        MergeStrategy { old, new in
            old[keyPath: keyPath()] < new[keyPath: keyPath()]
            ? strategies.reduce(new) { result, strategy in strategy.merge(old, new: result) }
            : strategies.reduce(old) { result, strategy in strategy.merge(new, new: result) }

        }
    }
}

public extension MergeStrategy {

    static func patch<Entity, Value>(
        _ keyPath: @Sendable @escaping @autoclosure () -> WritableKeyPath<Entity, Value?>
    ) -> MergeStrategy<Entity> {

        MergeStrategy<Entity> { old, new in
            var new = new
            new[keyPath: keyPath()] = new[keyPath: keyPath()] ?? old[keyPath: keyPath()]
            return new
        }
    }

    static func patch<Value>() -> MergeStrategy<Value?> where T == Value? {
        MergeStrategy<Value?> { old, new in
            new ?? old
        }
    }
}

public extension MergeStrategy {
    static func append<Entity, Value>(
        _ keyPath: @Sendable @escaping @autoclosure () -> WritableKeyPath<Entity, [Value]>
    ) -> MergeStrategy<Entity> {

        MergeStrategy<Entity> { old, new in
            var new = new
            new[keyPath: keyPath()] = [old[keyPath: keyPath()], new[keyPath: keyPath()]].flatMap { $0 }
            return new
        }
    }

    static func append<Entity, Value>(
        _ keyPath: @Sendable @escaping @autoclosure () -> WritableKeyPath<Entity, [Value]?>
    ) -> MergeStrategy<Entity> {

        MergeStrategy<Entity> { old, new in
            var new = new
            let result = [old[keyPath: keyPath()], new[keyPath: keyPath()]]
                .compactMap { $0 }
                .flatMap { $0 }
            new[keyPath: keyPath()] = result.isEmpty ? nil : result
            return new
        }
    }
}
