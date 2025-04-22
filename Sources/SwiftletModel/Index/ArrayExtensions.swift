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
