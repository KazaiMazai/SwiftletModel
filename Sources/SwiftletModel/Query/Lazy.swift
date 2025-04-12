//
//  Lazy.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/04/2025.
//

public struct Lazy<Entity: EntityModelProtocol, Result, Metadata> {
    typealias Resolver = () -> Result
    
    public let metadata: Metadata
    
    let context: Context
    let resolver: Resolver
}
