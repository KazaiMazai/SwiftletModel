//
//  ContextQuery.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/04/2025.
//

public struct ContextQuery<Entity: EntityModelProtocol, Result, Key> {
    let context: Context
    let key: (Context) -> Key?
    let result: (Context, Key?) -> Result
}
