//
//  OmitableCoding.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 12/03/2025.
//

import Foundation

public typealias OmitableFromCoding = OmitableFromEncoding & OmitableFromDecoding

public protocol OmitableFromEncoding: Encodable { }

extension KeyedDecodingContainer {
    public func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T: OmitableFromDecoding {
        return try decodeIfPresent(T.self, forKey: key) ?? T(wrappedValue: nil)
    }
}


extension KeyedEncodingContainer {
    public mutating func encode<T>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws where T: OmitableFromEncoding {
        return
    }
}

extension OmitableFromEncoding {
    public func encode(to encoder: Encoder) throws { }
}


public protocol OmitableFromDecoding: Decodable {
    associatedtype WrappedType: ExpressibleByNilLiteral
    init(wrappedValue: WrappedType)
}

extension OmitableFromDecoding {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: nil)
    }
}
