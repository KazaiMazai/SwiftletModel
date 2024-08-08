//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/08/2024.
//

import Foundation

@attached(extension, conformances: EntityModelProtocol, names: arbitrary)
public macro EntityModel() =
  #externalMacro(
    module: "SwiftletModelMacros", type: "EntityModelMacro"
  )
