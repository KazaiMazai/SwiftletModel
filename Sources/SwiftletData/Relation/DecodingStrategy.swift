//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 19/07/2024.
//

import Foundation

struct RelationDecodingStrategy: OptionSet {
    static let `default`: Self = [.plain]
    static let userInfoKey = CodingUserInfoKey(rawValue: "RelationDecodingStrategy.userInfoKey")!
    
    let rawValue: UInt
    
    static let plain = RelationDecodingStrategy(rawValue: 1 << 0)
    static let keyedContainer = RelationDecodingStrategy(rawValue: 1 << 1)
    static let explicitKeyedContainer = RelationDecodingStrategy(rawValue: 1 << 2) 
}

extension Decoder {
    var relationDecodingStrategy: RelationDecodingStrategy {
        get {
            (userInfo[RelationDecodingStrategy.userInfoKey] as? RelationDecodingStrategy) ?? .default
        }
    }
}
 
extension JSONDecoder {
    var relationDecodingStrategy: RelationDecodingStrategy {
        get {
            (userInfo[RelationDecodingStrategy.userInfoKey] as? RelationDecodingStrategy) ?? .default
        }
        set {
            userInfo[RelationDecodingStrategy.userInfoKey] = newValue
        }
    }
}
