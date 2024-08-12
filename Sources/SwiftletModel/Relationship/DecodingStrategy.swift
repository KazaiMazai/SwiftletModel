//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 19/07/2024.
//

import Foundation

public struct RelationDecodingStrategy: OptionSet, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

public extension RelationDecodingStrategy {
    static let `default`: Self = [.plain]

    static let plain = RelationDecodingStrategy(rawValue: 1 << 0)
    static let keyedContainer = RelationDecodingStrategy(rawValue: 1 << 1)
    static let explicitKeyedContainer = RelationDecodingStrategy(rawValue: 1 << 2)
}

public extension RelationDecodingStrategy {
    static let userInfoKey = CodingUserInfoKey(rawValue: "RelationDecodingStrategy.userInfoKey")!
}

public extension Decoder {
    var relationDecodingStrategy: RelationDecodingStrategy {
        (userInfo[RelationDecodingStrategy.userInfoKey] as? RelationDecodingStrategy) ?? .default
    }
}

public extension JSONDecoder {
    var relationDecodingStrategy: RelationDecodingStrategy {
        get {
            (userInfo[RelationDecodingStrategy.userInfoKey] as? RelationDecodingStrategy) ?? .default
        }
        set {
            userInfo[RelationDecodingStrategy.userInfoKey] = newValue
        }
    }
}
