//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation

@propertyWrapper
public struct Index<Entity, T: Comparable>: Sendable, Codable {
    public var wrappedValue: T.Type {
        T.self
    }
    
    public init(_ keyPath: KeyPath<Entity, T>) {
        
    }

    public init<T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) where T == Pair<T0, T1> {

    }

    public init<T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) where T == Triplet<T0, T1, T2> {

    }

    public init<T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) where T == Quadruple<T0, T1, T2, T3> {

    }
}

