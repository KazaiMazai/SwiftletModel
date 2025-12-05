//
//  Fetched.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 05/12/2025.
//

import Foundation
import SwiftletModel

@freestanding(expression)
public macro Fetch<Entity>(_ query: Query<Entity>) =
  #externalMacro(
    module: "SwiftletModelUIMacros", type: "FetchMacro"
  )
 
@freestanding(expression)
public macro Fetch<Entity>(_ query: QueryList<Entity>) =
  #externalMacro(
    module: "SwiftletModelUIMacros", type: "FetchMacro"
  )
