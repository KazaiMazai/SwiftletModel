//
//  File.swift
//  
//
//  Created by Serge Kazakov on 24/07/2024.
//

import Foundation

public enum RelationEncodingStrategy: Sendable {
    case plain
    case keyedContainer
    case explicitKeyedContainer
}

public extension RelationEncodingStrategy {
    static let `default`: Self = .plain
}

public extension RelationEncodingStrategy {
    static let userInfoKey = CodingUserInfoKey(rawValue: "RelationEncodingStrategy.userInfoKey")!
}

public extension Encoder {
    var relationEncodingStrategy: RelationEncodingStrategy {
        (userInfo[RelationEncodingStrategy.userInfoKey] as? RelationEncodingStrategy) ?? .default
    }
}

public extension JSONEncoder {
   var relationEncodingStrategy: RelationEncodingStrategy {
       get {
           (userInfo[RelationEncodingStrategy.userInfoKey] as? RelationEncodingStrategy) ?? .default
       }
       set {
           userInfo[RelationEncodingStrategy.userInfoKey] = newValue
       }
   }
}
