//
//  Lazy.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/04/2025.
//

public struct Lazy<Entity: EntityModelProtocol, Result, Key> {
    typealias Resolver = () -> Result
    typealias KeyResolver = () -> Key?
    
    let key: KeyResolver
    
    let context: Context
    let resolver: Resolver
}
