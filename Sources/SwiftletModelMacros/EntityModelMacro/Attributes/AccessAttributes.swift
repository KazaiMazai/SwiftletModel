//
//  File.swift
//  
//
//  Created by Serge Kazakov on 11/09/2024.
//

import Foundation

enum AccessAttribute: String {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
    case `open`
    case missingAttribute = ""

    var name: String {
        rawValue
    }
}
