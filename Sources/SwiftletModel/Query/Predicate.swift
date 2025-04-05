//
//  Predicate.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 03/04/2025.
//

import Foundation

public extension KeyPath where Value: Comparable {
    static func == (lhs: KeyPath<Root, Value>, rhs: Value) -> Predicate<Root, Value> {
        Predicate(keyPath: lhs, method: .equal, value: rhs)
    }

    static func < (lhs: KeyPath<Root, Value>, rhs: Value) -> Predicate<Root, Value> {
        Predicate(keyPath: lhs, method: .lessThan, value: rhs)
    }

    static func > (lhs: KeyPath<Root, Value>, rhs: Value) -> Predicate<Root, Value> {
        Predicate(keyPath: lhs, method: .greaterThan, value: rhs)
    }   

    static func != (lhs: KeyPath<Root, Value>, rhs: Value) -> Predicate<Root, Value> {
        Predicate(keyPath: lhs, method: .notEqual, value: rhs)
    }

    static func <= (lhs: KeyPath<Root, Value>, rhs: Value) -> Predicate<Root, Value> {
        Predicate(keyPath: lhs, method: .lessThanOrEqual, value: rhs)
    }

    static func >= (lhs: KeyPath<Root, Value>, rhs: Value) -> Predicate<Root, Value> {
        Predicate(keyPath: lhs, method: .greaterThanOrEqual, value: rhs)
    }   
}

public extension KeyPath where Value: Equatable {
    static func == (lhs: KeyPath<Root, Value>, rhs: Value) -> EqualityPredicate<Root, Value> {
        EqualityPredicate(keyPath: lhs, method: .equal, value: rhs)
    }
    
    static func != (lhs: KeyPath<Root, Value>, rhs: Value) -> EqualityPredicate<Root, Value> {
        EqualityPredicate(keyPath: lhs, method: .notEqual, value: rhs)
    }
}

public extension KeyPath where Value == String {
    static func contains(lhs: KeyPath<Root, Value>, rhs: String) -> StringPredicate<Root> {
        StringPredicate(keyPath: lhs, method: .contains, value: rhs)
    }

    static func startsWith(lhs: KeyPath<Root, Value>, rhs: String) -> StringPredicate<Root> {
        StringPredicate(keyPath: lhs, method: .startsWith, value: rhs)
    }
    
    static func endsWith(lhs: KeyPath<Root, Value>, rhs: String) -> StringPredicate<Root> {
        StringPredicate(keyPath: lhs, method: .endsWith, value: rhs)
    }
    
    static func matches(lhs: KeyPath<Root, Value>, rhs: String) -> StringPredicate<Root> {
        StringPredicate(keyPath: lhs, method: .matches, value: rhs)
    }
}

public struct Predicate<Entity, Value: Comparable> {
    let keyPath: KeyPath<Entity, Value>
    let method: Method
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
        case .lessThanOrEqual:
            entity[keyPath: keyPath] <= value
        case .greaterThanOrEqual:
            entity[keyPath: keyPath] >= value   
        }
    }
    
    enum Method {
        case equal
        case lessThan
        case lessThanOrEqual
        case greaterThan
        case greaterThanOrEqual
        case notEqual
    }
}

public struct EqualityPredicate<Entity, Value: Equatable> {
    let keyPath: KeyPath<Entity, Value>
    let method: Method
    let value: Value
 
    func isIncluded(_ entity: Entity) -> Bool {
        switch method {
        case .equal:
            entity[keyPath: keyPath] == value
        case .notEqual:
            entity[keyPath: keyPath] != value
        }
    }
    
    enum Method {
        case equal
        case notEqual
    }
}

public struct StringPredicate<Entity> {
    let keyPath: KeyPath<Entity, String>
    let method: Method
    let value: String
    
    func isIncluded(_ entity: Entity) -> Bool {
        switch method {
        case .contains:
            entity[keyPath: keyPath].contains(value)
        case .startsWith:
            entity[keyPath: keyPath].hasPrefix(value)
        case .endsWith:
            entity[keyPath: keyPath].hasSuffix(value)
        case .matches:
            entity[keyPath: keyPath].fuzzyMatches(value)
        }
    }
    
    enum Method {
        case contains
        case startsWith
        case endsWith
        case matches
    }
}
