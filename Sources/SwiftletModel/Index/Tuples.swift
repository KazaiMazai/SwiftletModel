//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 08/03/2025.
//

import Foundation

struct Pair<T0, T1> {
    let t0: T0
    let t1: T1
}

extension Pair: Hashable where T0: Hashable,
                               T1: Hashable {
    
}

extension Pair: Equatable where T0: Equatable,
                                T1: Equatable {
    
}

extension Pair: Sendable where T0: Sendable,
                              T1: Sendable {
    
}

extension Pair: Comparable where T0: Comparable,
                                 T1: Comparable {
    
    static func < (lhs: Pair<T0, T1>, rhs: Pair<T0, T1>) -> Bool {
        (lhs.t0, lhs.t1) < (rhs.t0, rhs.t1)
    }
}

struct Triplet<T0, T1, T2> {
    let t0: T0
    let t1: T1
    let t2: T2
}

extension Triplet: Equatable where T0: Equatable,
                                   T1: Equatable,
                                   T2: Equatable {
    
}

extension Triplet: Sendable where T0: Sendable,
                                  T1: Sendable,
                                  T2: Sendable {
    
}

extension Triplet: Comparable where T0: Comparable,
                                    T1: Comparable,
                                    T2: Comparable {
    
    static func < (lhs: Triplet<T0, T1, T2>, rhs: Triplet<T0, T1, T2>) -> Bool {
        (lhs.t0, lhs.t1, lhs.t2) < (rhs.t0, rhs.t1, rhs.t2)
    }
}

extension Triplet: Hashable where T0: Hashable,
                                  T1: Hashable,
                                  T2: Hashable {
}

struct Quadruple<T0, T1, T2, T3> {
    let t0: T0
    let t1: T1
    let t2: T2
    let t3: T3
}

extension Quadruple: Equatable where T0: Equatable,
                                     T1: Equatable,
                                     T2: Equatable,
                                     T3: Equatable {
    
}

extension Quadruple: Comparable where T0: Comparable,
                                      T1: Comparable,
                                      T2: Comparable,
                                      T3: Comparable {
    
    static func < (lhs: Quadruple<T0, T1, T2, T3>, rhs: Quadruple<T0, T1, T2, T3>) -> Bool {
        (lhs.t0, lhs.t1, lhs.t2, lhs.t3) < (rhs.t0, rhs.t1, rhs.t2, rhs.t3)
    }
}

extension Quadruple: Hashable where T0: Hashable,
                                    T1: Hashable,
                                    T2: Hashable,
                                    T3: Hashable {
}

extension Quadruple: Sendable where T0: Sendable,
                                    T1: Sendable,
                                    T2: Sendable,
                                    T3: Sendable {
}

func indexValue<T0, T1>(_ tuple: (T0, T1)) -> Pair<T0, T1> {
    Pair(t0: tuple.0, t1: tuple.1)
}

func indexValue<T0, T1, T2>(_ tuple: (T0, T1, T2)) -> Triplet<T0, T1, T2> {
    Triplet(t0: tuple.0, t1: tuple.1, t2: tuple.2)
}

func indexValue<T0, T1, T2, T3>(_ tuple: (T0, T1, T2, T3)) -> Quadruple<T0, T1, T2, T3> {
    Quadruple(t0: tuple.0, t1: tuple.1, t2: tuple.2, t3: tuple.3)
}
