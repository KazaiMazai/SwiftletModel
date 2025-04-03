//
//  Predicate.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 03/04/2025.
//

import Foundation

public extension KeyPath where Value: Comparable {
    func equal(_ value: Value) -> Predicate<Root, Value> {
        Predicate(method: .equal, keyPath: self, value: value)
    }

    func lessThan(_ value: Value) -> Predicate<Root, Value> {
        Predicate(method: .lessThan, keyPath: self, value: value)
    }

    func greaterThan(_ value: Value) -> Predicate<Root, Value> {
        Predicate(method: .greaterThan, keyPath: self, value: value)
    }

    func notEqual(_ value: Value) -> Predicate<Root, Value> {
        Predicate(method: .notEqual, keyPath: self, value: value)
    }
}

public struct Predicate<Entity, Value: Comparable> {
    let method: Method
    let keyPath: KeyPath<Entity, Value>
    let value: Value
 
    func isIncluded(_ entity: Entity) -> Bool {
        switch method {
        case .equal:
            entity[keyPath: keyPath] == value
        case .lessThan:
            entity[keyPath: keyPath] < value
        case .greaterThan:
            entity[keyPath: keyPath] > value
        case .notEqual:
            entity[keyPath: keyPath] != value
        }
    }
    
    enum Method {
        case equal
        case lessThan
        case greaterThan
        case notEqual
    }
}
