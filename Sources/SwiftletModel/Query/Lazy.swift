//
//  Lazy.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/04/2025.
//

public struct Lazy<Entity: EntityModelProtocol, Result, Key> {
    typealias Resolver = (Context, Key?) -> Result
    typealias KeyResolver = (Context) -> Key?
    
    let keyResolver: KeyResolver
    
    let context: Context
    let resolver: Resolver
}
