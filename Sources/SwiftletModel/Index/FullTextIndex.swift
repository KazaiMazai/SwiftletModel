//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 08/03/2025.
//

import Foundation

@MainActor
@propertyWrapper
public struct FullTextIndex<Entity: EntityModelProtocol>: Sendable, Codable {

    public var wrappedValue: Never.Type {
        Never.self
    }

    public init(_ keypaths: KeyPath<Entity, String>...) {

    }
}
