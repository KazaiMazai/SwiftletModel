//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

extension IdentifiableEntity {
    func merged<Property>(_ keyPath: WritableKeyPath<Self, Property?>,
                          with existing: Self,
                          merge: Merge<Property?>) -> Self {
         
        var selfCopy = self
        selfCopy[keyPath: keyPath] = merge.merge(existing[keyPath: keyPath], self[keyPath: keyPath])
        return selfCopy
    }
    
    func merged<Property>(_ keyPath: WritableKeyPath<Self, Property>,
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
    static var replace: Merge<T> {
        Merge(merge: { _, new in new })
    }
}

extension Merge {
    static func newIfExist<T>() -> Merge<Optional<T>>   {
        Merge<Optional<T>> { old, new in
            new ?? old
        }
    }
    
    static func append<T>() -> Merge<[T]>   {
        Merge<[T]> { old, new in
            [old, new].flatMap { $0 }
        }
    }
    
    static func append<T>() -> Merge<Optional<[T]>>   {
        Merge<Optional<[T]>> { old, new in
            Merge<[T]>
                .append()
                .merge(old ?? [], new ?? [])
                                    
        }
    }
}
