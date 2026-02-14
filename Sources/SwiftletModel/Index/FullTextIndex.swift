//
//  FullTextIndex.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 08/03/2025.
//

import Foundation

@propertyWrapper
public struct FullTextIndex<Entity: EntityModelProtocol>: Sendable, OmitableFromCoding {
    public var wrappedValue: Never? { nil }

    public init(wrappedValue: Never?) { }

    public init(_ keypaths: KeyPath<Entity, String>...) { }
}
