//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 15/06/2025.
//

import Foundation

extension Relation {
    func updateOption<Parent>() -> Link<Parent, Entity>.UpdateOption {
        isSlice ? .append : .replace
    }

    static func inverseUpdateOption<Parent>() -> Link<Parent, Entity>.UpdateOption {
        Cardinality.isToMany ? .append : .replace
    }
}
