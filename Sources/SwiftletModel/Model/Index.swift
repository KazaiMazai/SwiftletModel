//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16/08/2024.
//

import Foundation


extension EntityModelProtocol {
    
    func updateIndex<T0, T1>(_ kp0: KeyPath<Self, T0>,
                             _ kp1: KeyPath<Self, T1>,
                             in context: inout Context) throws where T0: Comparable, T1: Comparable {
        
        var index = index(kp0, kp1, in: context)
        index.update(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1])))
        try index.save(to: &context)
    }
}

extension EntityModelProtocol {
    
    
    func index<T>(_ keyPath: KeyPath<Self, T>,
                  in context: Context) -> IndexModel<Self, T> {
        
        IndexModel
            .query(indexName(keyPath), in: context)
            .resolve() ?? IndexModel(name: indexName(keyPath))
        
    }
    
    func index<T0, T1>(_ kp0: KeyPath<Self, T0>,
                       _ kp1: KeyPath<Self, T1>,
                       in context: Context) -> IndexModel<Self, Pair<T0, T1>> {
        
        IndexModel
            .query(indexName(kp0, kp1), in: context)
            .resolve() ?? IndexModel(name: indexName(kp0, kp1))
        
    }
    
    func index<T0, T1, T2>(_ kp0: KeyPath<Self, T0>,
                           _ kp1: KeyPath<Self, T1>,
                           _ kp2: KeyPath<Self, T2>,
                           in context: Context) -> IndexModel<Self, Triplet<T0, T1, T2>> {
        
        IndexModel
            .query(indexName(kp0, kp1, kp2), in: context)
            .resolve() ?? IndexModel(name: indexName(kp0, kp1, kp2))
        
    }
    
    func index<T0, T1, T2, T3>(_ kp0: KeyPath<Self, T0>,
                               _ kp1: KeyPath<Self, T1>,
                               _ kp2: KeyPath<Self, T2>,
                               _ kp3: KeyPath<Self, T3>,
                               in context: Context) -> IndexModel<Self, Quadruple<T0, T1, T2, T3>> {
        
        IndexModel
            .query(indexName(kp0, kp1, kp2, kp3), in: context)
            .resolve() ?? IndexModel(name: indexName(kp0, kp1, kp2, kp3))
        
    }
}

extension EntityModelProtocol {
    func indexName<T>(_ keyPath: KeyPath<Self, T>) -> String {
        keyPath.name
    }
    
    func indexName<T0, T1>(_ kp0: KeyPath<Self, T0>,
                           _ kp1: KeyPath<Self, T1>) -> String {
        
        [kp0, kp1]
            .map { $0.name }
            .joined(separator: "-")
    }
    
    func indexName<T0, T1, T2>(_ kp0: KeyPath<Self, T0>,
                               _ kp1: KeyPath<Self, T1>,
                               _ kp2: KeyPath<Self, T2>) -> String {
        
        [kp0, kp1, kp2]
            .map { $0.name }
            .joined(separator: "-")
    }
    
    func indexName<T0, T1, T2, T3>(_ kp0: KeyPath<Self, T0>,
                                   _ kp1: KeyPath<Self, T1>,
                                   _ kp2: KeyPath<Self, T2>,
                                   _ kp3: KeyPath<Self, T3>) -> String {
        
        [kp0, kp1, kp2, kp3]
            .map { $0.name }
            .joined(separator: "-")
        
    }
}
