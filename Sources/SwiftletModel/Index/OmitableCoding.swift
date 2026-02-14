//
//  OmitableCoding.swift
//  SwiftletModel
//
//  Based on OmitCodingWrappers by PJ Fechner
//

import Foundation

/// Marker type for index property wrappers
public enum Indexed: Sendable, Codable {
    case marker
}

// MARK: - OmitCoding protocols

/// Protocol to indicate instances should be skipped when encoding
public protocol OmitableFromEncoding: Encodable { }

extension OmitableFromEncoding {
    // This shouldn't ever be called since KeyedEncodingContainer should skip it due to the included extension
    public func encode(to encoder: Encoder) throws { }
}

extension KeyedEncodingContainer {
    // Used to make sure OmitableFromEncoding never encodes a value
    public mutating func encode<T>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws where T: OmitableFromEncoding {
        return
    }
}

/// Protocol to indicate instances should be skipped when decoding
public protocol OmitableFromDecoding: Decodable {
    associatedtype WrappedType: ExpressibleByNilLiteral
    init(wrappedValue: WrappedType)
}

extension OmitableFromDecoding {
    /// Inits the value with nil
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: nil)
    }
}

extension KeyedDecodingContainer {
    // This is used to override the default decoding behavior to allow a value to avoid a missing key Error
    public func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T: OmitableFromDecoding {
        return try decodeIfPresent(T.self, forKey: key) ?? T(wrappedValue: nil)
    }
}

/// Combination of OmitableFromEncoding and OmitableFromDecoding
public typealias OmitableFromCoding = OmitableFromEncoding & OmitableFromDecoding
