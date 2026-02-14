//
//  FullTextIndex.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 08/03/2025.
//

import Foundation

@propertyWrapper
public struct FullTextIndex<Entity: EntityModelProtocol>: Sendable, OmitableFromCoding {
    public var wrappedValue: Indexed?

    public init(wrappedValue: Indexed?) {
        self.wrappedValue = wrappedValue
    }

    public init(_ keypaths: KeyPath<Entity, String>...) {
        self.wrappedValue = .marker
    }
}
