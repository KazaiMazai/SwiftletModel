//
//  KeyPathExtensions.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 15/06/2025.
//


extension KeyPath {
    var ValueType: Value.Type {
        Value.self
    }
}

extension PartialKeyPath {
    var name: String {
        String(describing: self)
    }
}
