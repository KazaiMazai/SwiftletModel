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
    let keyPaths: [KeyPath<Entity, String>]
    let method: Method
    let value: String
    
    func isIncluded(_ entity: Entity) -> Bool {
        switch method {
        case .contains(let caseSensitive):
            keyPaths.contains { entity[keyPath: $0].contains(value, caseSensitive: caseSensitive) }
        case .hasPrefix(let caseSensitive):
            keyPaths.contains { entity[keyPath: $0].hasPrefix(value, caseSensitive: caseSensitive) }
        case .hasSuffix(let caseSensitive):
            keyPaths.contains { entity[keyPath: $0].hasSuffix(value, caseSensitive: caseSensitive) }
        case .matches(let tokens):
            keyPaths.contains { entity[keyPath: $0].matches(tokens: tokens) }
        case .notHavingPrefix(let caseSensitive):
            !keyPaths.contains { entity[keyPath: $0].hasPrefix(value, caseSensitive: caseSensitive) }
        case .notHavingSuffix(let caseSensitive):
            !keyPaths.contains { entity[keyPath: $0].hasSuffix(value, caseSensitive: caseSensitive) }
        }
    }
    
    enum Method {
        case contains(caseSensitive: Bool)
        case hasPrefix(caseSensitive: Bool)
        case hasSuffix(caseSensitive: Bool)
        case matches(tokens: [String])
        case notHavingPrefix(caseSensitive: Bool)
        case notHavingSuffix(caseSensitive: Bool)

        var isMatching: Bool {
            switch self {
            case .matches:
                return true
            default:
                return false
            }
        }
        
        var isIncluding: Bool {
            switch self {
            case .contains, .hasPrefix, .hasSuffix:
                return true
            default:
                return false
            }
        }
    }
}

public extension StringPredicate {
    static func string(_ keyPaths: KeyPath<Entity, String>...,
                       contains value: String,
                       caseSensitive: Bool = false) -> StringPredicate<Entity> {
        StringPredicate(keyPaths: keyPaths, method: .contains(caseSensitive: caseSensitive), value: value)
    }

    static func string(_ keyPaths: KeyPath<Entity,
                       String>...,
                       hasPrefix value: String,
                       caseSensitive: Bool = false) -> StringPredicate<Entity> {
        StringPredicate(keyPaths: keyPaths, method: .hasPrefix(caseSensitive: caseSensitive), value: value)
    }

    static func string(_ keyPaths: KeyPath<Entity, String>...,
                       hasSuffix value: String,
                       caseSensitive: Bool = false) -> StringPredicate<Entity> {
        StringPredicate(keyPaths: keyPaths, method: .hasSuffix(caseSensitive: caseSensitive), value: value)
    }

    static func string(_ keyPaths: KeyPath<Entity, String>...,
                       matches value: String) -> StringPredicate<Entity> {
        StringPredicate(keyPaths: keyPaths, method: .matches(tokens: value.makeTokens()), value: value)
    }

    static func string(_ keyPaths: KeyPath<Entity, String>...,
                       notHavingPrefix value: String,
                       caseSensitive: Bool = false) -> StringPredicate<Entity> {
        StringPredicate(keyPaths: keyPaths, method: .notHavingPrefix(caseSensitive: caseSensitive), value: value)
    }

    static func string(_ keyPaths: KeyPath<Entity, String>...,
                       notHavingSuffix value: String,
                       caseSensitive: Bool = false) -> StringPredicate<Entity> {
        StringPredicate(keyPaths: keyPaths, method: .notHavingSuffix(caseSensitive: caseSensitive), value: value)
    }
}

extension String {
    func contains(_ value: String, caseSensitive: Bool) -> Bool {
        caseSensitive ?
            contains(value) :
            lowercased().contains(value.lowercased())
    }

    func hasPrefix(_ value: String, caseSensitive: Bool) -> Bool {
        caseSensitive ?
            hasPrefix(value) :
            lowercased().hasPrefix(value.lowercased())
    }

    func hasSuffix(_ value: String, caseSensitive: Bool) -> Bool {
        caseSensitive ?
            hasSuffix(value) :
            lowercased().hasSuffix(value.lowercased())
    }
}
