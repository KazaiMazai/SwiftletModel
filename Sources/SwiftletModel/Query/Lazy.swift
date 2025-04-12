//
//  Lazy.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/04/2025.
//

public struct Lazy<Entity: EntityModelProtocol, Result, Key> {
    typealias Resolver = (Context, Key?) -> Result
    typealias KeyResolver = (Context) -> Key?
    
    let context: Context
    let keyResolver: KeyResolver
    let resolver: Resolver
}
