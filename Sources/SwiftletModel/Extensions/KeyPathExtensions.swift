//
//  KeyPathExtensions.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 15/06/2025.
//

extension KeyPath {
    var valueType: Value.Type {
        Value.self
    }
}
 
extension KeyPath where Root: EntityModelProtocol {
    var name: String {
        Root.propertyName(self)
    }
}
