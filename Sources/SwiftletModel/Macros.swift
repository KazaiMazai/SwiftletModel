//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/08/2024.
//

import Foundation

@attached(extension, conformances: ListablePropertiesProtocol, names: arbitrary)
public macro StorableEntity() =
  #externalMacro(
    module: "SwiftletModelMacros", type: "StorableEntityMacro"
  )
