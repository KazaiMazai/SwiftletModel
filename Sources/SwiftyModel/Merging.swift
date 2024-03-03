//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

extension IdentifiableEntity {
    func merge<Property>(_ keyPath: WritableKeyPath<Self, Property?>,
                          with existing: Self,
                          by merge: Merge<Property?>) -> Self {
         
        var selfCopy = self
        selfCopy[keyPath: keyPath] = merge.merge(existing[keyPath: keyPath], self[keyPath: keyPath])
        return selfCopy
    }
    
    func merge<Property>(_ keyPath: WritableKeyPath<Self, Property>,
                          with existing: Self,
                          merge: Merge<Property>) -> Self {
         
        var selfCopy = self
        selfCopy[keyPath: keyPath] = merge.merge(existing[keyPath: keyPath], self[keyPath: keyPath])
        return selfCopy
    }
}
 
struct Merge<T> {
    let merge: (T, T) -> T
}
 
extension Merge {
    static var replacing: Merge<T> {
        Merge(merge: { _, new in new })
    }
}

extension Merge {
    static func keepingOldIfNil<T>() -> Merge<Optional<T>>   {
        Merge<Optional<T>> { old, new in
            new ?? old
        }
    }
    
    static func appending<T>() -> Merge<[T]>   {
        Merge<[T]> { old, new in
            [old, new].flatMap { $0 }
        }
    }
    
    static func appending<T>() -> Merge<Optional<[T]>>   {
        Merge<Optional<[T]>> { old, new in
            let result = Merge<[T]>
                .appending()
                .merge(old ?? [], new ?? [])
            
            return result.isEmpty ? nil : result
        }
    }
}
