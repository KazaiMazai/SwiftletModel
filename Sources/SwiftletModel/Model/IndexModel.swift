//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 15/08/2024.
//

import Foundation
import BTree
import Collections

@EntityModel
struct IndexModel<Entity: EntityModelProtocol, Value: Comparable> {
    typealias IndexMap = Map<Value, OrderedSet<Entity.ID>>
    var id: String { name }
    
    let name: String
    
    private var indexMap: IndexMap = [:]
    private var indexValues: [Entity.ID: Value] = [:]
    
    init(name: String) {
        self.name = name
    }
    
    var sorted: [Entity.ID] { indexMap.flatMap { $0.1.elements } }
}

extension IndexModel {
    mutating func add(_ entity: Entity, value: Value) {
        let existingValue = indexValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, var ids = indexMap[existingValue] {
            ids.remove(entity.id)
            indexMap[existingValue] = ids.isEmpty ? nil : ids
        }
        
        guard var ids = indexMap[value] else {
            indexMap[value] = OrderedSet(arrayLiteral: entity.id)
            indexValues[entity.id] = value
            return
        }
        
        ids.append(entity.id)
        indexMap[value] = ids
        indexValues[entity.id] = value
    }
    
    mutating func remove(_ entity: Entity) {
        guard let value = indexValues[entity.id] else {
            return
        }
        
        guard var ids = indexMap[value] else {
            return
        }
        
        ids.remove(entity.id)
        indexMap[value] = ids
    }
}

extension IndexModel {
    func filter(_ value: Value) -> [Entity.ID] {
        indexMap[value]?.elements ?? []
    }
    
    func filter(range: Range<Value>) -> [Entity.ID] {
        indexMap
            .submap(from: range.lowerBound, to: range.upperBound)
            .map { $1.elements }
            .flatMap { $0 }
    }
    
    func grouped() -> [Value: [Entity.ID]] where Value: Hashable {
        Dictionary(indexMap.map { ($0, $1.elements) },
                   uniquingKeysWith: { $1 })
            
    }
}
 
struct Pair<T0, T1> {
    let t0: T0
    let t1: T1
}

extension Pair: Equatable where T0: Equatable,
                                T1: Equatable {
    
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

extension Triplet: Comparable where T0: Comparable,
                                    T1: Comparable,
                                    T2: Comparable {
    
    static func < (lhs: Triplet<T0, T1, T2>, rhs: Triplet<T0, T1, T2>) -> Bool {
        (lhs.t0, lhs.t1, lhs.t2) < (rhs.t0, rhs.t1, rhs.t2)
    }
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


func indexValue<T0, T1>(_ tuple: (T0, T1)) -> Pair<T0, T1> {
    Pair(t0: tuple.0, t1: tuple.1)
}

func indexValue<T0, T1, T2>(_ tuple: (T0, T1, T2)) -> Triplet<T0, T1, T2> {
    Triplet(t0: tuple.0, t1: tuple.1, t2: tuple.2)
}

func indexValue<T0, T1, T2, T3>(_ tuple: (T0, T1, T2, T3)) -> Quadruple<T0, T1, T2, T3> {
    Quadruple(t0: tuple.0, t1: tuple.1, t2: tuple.2, t3: tuple.3)
}
