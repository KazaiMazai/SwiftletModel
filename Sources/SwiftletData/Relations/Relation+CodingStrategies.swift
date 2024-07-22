//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 19/07/2024.
//

import Foundation

//MARK: - Encoding

enum RelationEncodingStrategy {
    static let `default`: Self = .plain
    
    static let userInfoKey = CodingUserInfoKey(rawValue: "RelationEncodingStrategy.userInfoKey")!
 
    case plain
    case explicit
    case exact
}


struct RelationDecodingStrategy: OptionSet {
    static let `default`: Self = [.plain]
    static let userInfoKey = CodingUserInfoKey(rawValue: "RelationDecodingStrategy.userInfoKey")!
    
    let rawValue: UInt
    
    static let plain = RelationDecodingStrategy(rawValue: 1 << 0)
    static let explicit = RelationDecodingStrategy(rawValue: 1 << 1)
    static let exact = RelationDecodingStrategy(rawValue: 1 << 2)
    
    static let lossy = RelationDecodingStrategy(rawValue: 1 << 3)
 
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

extension Encoder {
    var relationEncodingStrategy: RelationEncodingStrategy {
        get {
            (userInfo[RelationEncodingStrategy.userInfoKey] as? RelationEncodingStrategy) ?? .default
        }
    }
}

extension JSONEncoder {
   var relationEncodingStrategy: RelationEncodingStrategy {
       get {
           (userInfo[RelationEncodingStrategy.userInfoKey] as? RelationEncodingStrategy) ?? .default
       }
       set {
           userInfo[RelationEncodingStrategy.userInfoKey] = newValue
       }
   }
}

extension Encodable  {
    func prettyDescription(with encoder: JSONEncoder) -> String? {
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

extension JSONEncoder {
    static var prettyPrinting: JSONEncoder {
        let encoder = JSONEncoder()
        if #available(macOS 10.15, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        } else {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        return encoder
    }
}
