//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 11/07/2024.
//

import Foundation

struct Link<Parent: EntityModel, Child: EntityModel> {
    let parent: Parent.ID
    let children: [Child.ID]
    let direct: LinkAttribute
    let inverse: LinkAttribute?
}

enum Option {
    case append
    case replace
    case remove
}

struct LinkAttribute {
    let name: String
    let updateOption: Option
}

