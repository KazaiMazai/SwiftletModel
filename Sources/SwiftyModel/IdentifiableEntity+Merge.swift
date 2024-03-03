//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation

extension IdentifiableEntity {
    func merge<Property>(_ keyPath: WritableKeyPath<Self, Property>,
                          with existing: Self,
                          using mergeStrategy: MergeStrategy<Property>) -> Self {
         
        var selfCopy = self
        selfCopy[keyPath: keyPath] = mergeStrategy.merge(existing[keyPath: keyPath], self[keyPath: keyPath])
        return selfCopy
    }
}
