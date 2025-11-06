//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 09/03/2025.
//

import Foundation

extension String {
    static func indexName<Entity, T>(
        _ keyPath: KeyPath<Entity, T>) -> String where Entity: EntityModelProtocol {
        keyPath.name
    }

    static func indexName<Entity, T>(
        _ keyPaths: [KeyPath<Entity, T>]) -> String where Entity: EntityModelProtocol {
            keyPaths
                .map { $0.name }
                .joined(separator: "-")
    }

    static func indexName<Entity, T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> String where Entity: EntityModelProtocol {

            [kp0.name, kp1.name]
                .joined(separator: "-")
    }

    static func indexName<Entity, T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> String where Entity: EntityModelProtocol {

            [kp0.name, kp1.name, kp2.name]
                .joined(separator: "-")
    }

    static func indexName<Entity, T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> String where Entity: EntityModelProtocol {

        [kp0.name, kp1.name, kp2.name, kp3.name]
            .joined(separator: "-")
    }
}
