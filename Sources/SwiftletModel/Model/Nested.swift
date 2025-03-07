//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 07/03/2025.
//

import Foundation

public enum Nested {
    case none
    case ids
    case entities
    case fragments
    case depth(depth: Int)
    
    public var next: Nested {
        switch self {
        case .none:
            return .none
        case .ids:
            return .none
        case .entities, .fragments:
            return .none
        case .depth(let depth):
            return Nested(depth - 1)
        }
    }
    
    var depth: Int {
        switch self {
        case .none:
            return .zero
        case .ids:
            return 1
        case .entities, .fragments:
            return -1
        case .depth(let depth):
            return depth
        }
    }
    
    init(_ depth: Int) {
        guard depth > 0 else {
            self = .none
            return
        }
        
        guard depth > 1 else {
            self = .ids
            return
        }
        
        self = .depth(depth: depth)
    }
    
}
