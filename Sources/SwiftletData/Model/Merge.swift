//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public struct MergeStrategy<T> {
    let merge: (_ old: T, _ new: T) -> T
    
    public init(merge: @escaping (T, T) -> T) {
        self.merge = merge
    }
}
 
public extension MergeStrategy {
    static var replace: MergeStrategy<T> {
        MergeStrategy(merge: { _, new in new })
    }
}

public extension MergeStrategy {
    init(_ strategies: MergeStrategy<T>...) {
        merge = { old, new in
            strategies.reduce(new, { result, strategy in
                strategy.merge(old, result)
            })
        }
    }
}

public extension MergeStrategy {
    
    static func patch<Entity, Value>(_ keyPath: WritableKeyPath<Entity, Optional<Value>>) -> MergeStrategy<Entity>   {
        MergeStrategy<Entity> { old, new in
            var new = new
            new[keyPath: keyPath] = new[keyPath: keyPath] ?? old[keyPath: keyPath]
            return new
        }
    }
    
    static func patch<Value>() -> MergeStrategy<Optional<Value>>   {
        MergeStrategy<Optional<Value>> { old, new in
            new ?? old
        }
    }
}

public extension MergeStrategy {
    static func append<Entity, Value>(_ keyPath: WritableKeyPath<Entity, [Value]>) -> MergeStrategy<Entity>   {
        MergeStrategy<Entity> { old, new in
            var new = new
            new[keyPath: keyPath] = [old[keyPath: keyPath], new[keyPath: keyPath]].flatMap { $0 }
            return new
        }
    }
    
    static func append<Entity, Value>(_ keyPath: WritableKeyPath<Entity, Optional<[Value]>>) -> MergeStrategy<Entity>   {
        MergeStrategy<Entity> { old, new in
            var new = new
            let result = [old[keyPath: keyPath], new[keyPath: keyPath]]
                .compactMap { $0 }
                .flatMap { $0 }
            new[keyPath: keyPath] = result.isEmpty ? nil : result
            return new
        }
    }
}

