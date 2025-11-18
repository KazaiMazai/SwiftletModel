//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 03/04/2025.
//

import Foundation

extension Array {
    func removingDuplicates<Key: Hashable>(by key: (Element) -> Key) -> [Element] {
        var existingDict = [Key: Bool]()

        return filter {
            existingDict.updateValue(true, forKey: key($0)) == nil
        }
    }
}

extension Array {
    func limit(_ limit: Int, offset: Int) -> Array {
        guard limit > 0, offset >= 0
        else {
            return []
        }
        return Array(dropFirst(offset).prefix(limit))
    }
}
