//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation

public enum Nested {
    case ids
    case entities
    case fragments
    case entitiesSlice(MetadataPredicate)
    case fragmentsSlice(MetadataPredicate)
    
}
