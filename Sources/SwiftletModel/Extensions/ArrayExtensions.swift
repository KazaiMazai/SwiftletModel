//
//  ArrayExtensions.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 17/11/2025.
//

import Foundation

extension Array {
    func limit(_ limit: Int, offset: Int) -> Array {
        guard limit > 0,
              offset >= 0,
              offset < count
        else {
            return []
        }
        
        let upperBounds = Swift.min(count, offset + limit)
        return Array(self[offset..<offset + limit])
    }
}
