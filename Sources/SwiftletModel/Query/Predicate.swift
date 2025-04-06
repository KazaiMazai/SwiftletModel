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

infix operator ~~ : ComparisonPrecedence   // contains
infix operator ^~ : ComparisonPrecedence   // starts with
infix operator ~^ : ComparisonPrecedence   // ends with
infix operator ~= : ComparisonPrecedence   // fuzzy matches
public extension KeyPath where Value == String {
    static func ~= (lhs: KeyPath<Root, String>, rhs: String) -> StringPredicate<Root> {
        StringPredicate(keyPath: lhs, method: .matches, value: rhs)
    }

    static func ~~ (lhs: KeyPath<Root, String>, rhs: String) -> StringPredicate<Root> {
        StringPredicate(keyPath: lhs, method: .contains, value: rhs)
    }
    
    static func ~^ (lhs: KeyPath<Root, String>, rhs: String) -> StringPredicate<Root> {
        StringPredicate(keyPath: lhs, method: .hasSuffix, value: rhs)
    }
    
    static func ^~ (lhs: KeyPath<Root, String>, rhs: String) -> StringPredicate<Root> {
        StringPredicate(keyPath: lhs, method: .hasPrefix, value: rhs)
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
        case .hasPrefix:
            entity[keyPath: keyPath].hasPrefix(value)
        case .hasSuffix:
            entity[keyPath: keyPath].hasSuffix(value)
        case .matches:
            entity[keyPath: keyPath].fuzzyMatches(value)
        }
    }
    
    public enum Method {
        case contains
        case hasPrefix
        case hasSuffix
        case matches
    }
}

public extension StringPredicate {
    static func string(_ keyPath: KeyPath<Entity, String>, contains value: String) -> StringPredicate<Entity> {
        StringPredicate(keyPath: keyPath, method: .contains, value: value)
    }

    static func string(_ keyPath: KeyPath<Entity, String>, hasPrefix value: String) -> StringPredicate<Entity> {
        StringPredicate(keyPath: keyPath, method: .hasPrefix, value: value)
    }

    static func string(_ keyPath: KeyPath<Entity, String>, hasSuffix value: String) -> StringPredicate<Entity> {
        StringPredicate(keyPath: keyPath, method: .hasSuffix, value: value)
    }

    static func string(_ keyPath: KeyPath<Entity, String>, matches value: String) -> StringPredicate<Entity> {
        StringPredicate(keyPath: keyPath, method: .matches, value: value)
    }
}
