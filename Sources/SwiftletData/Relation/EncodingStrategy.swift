//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24/07/2024.
//

import Foundation


enum RelationEncodingStrategy {
    static let `default`: Self = .plain
    
    static let userInfoKey = CodingUserInfoKey(rawValue: "RelationEncodingStrategy.userInfoKey")!
 
    case plain
    case keyedContainer
    case explicitKeyedContainer
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
