//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 09/03/2025.
//

import Foundation

extension String {
    static func indexName<Entity, T>(
        _ keyPath: KeyPath<Entity, T>) -> String {
        keyPath.name
    }
    
    static func indexName<Entity, T>(
        _ keyPaths: [KeyPath<Entity, T>]) -> String {
            keyPaths
                .map { $0.name }
                .joined(separator: "-")
    }
    
    static func indexName<Entity, T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> String {
        
        [kp0, kp1]
            .map { $0.name }
            .joined(separator: "-")
    }
    
    static func indexName<Entity, T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> String {
        
        [kp0, kp1, kp2]
            .map { $0.name }
            .joined(separator: "-")
    }
    
    static func indexName<Entity, T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> String {
        
        [kp0, kp1, kp2, kp3]
            .map { $0.name }
            .joined(separator: "-")
    }
}
