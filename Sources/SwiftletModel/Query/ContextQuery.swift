//
//  ContextQuery.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 12/04/2025.
//

public struct ContextQuery<Entity: EntityModelProtocol, Result, Key> {
    let context: Context
    let key: (Context) -> Key?
    let result: (Context, Key?) -> Result
}
