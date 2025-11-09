//
//  ContextQuery.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 12/04/2025.
//

public struct ContextQuery<Entity: EntityModelProtocol, Result, Key> {
    let key: (Context) -> Key?
    let value: (Context, Key?) -> Result
}
