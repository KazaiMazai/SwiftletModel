//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 05/04/2025.
//

import Foundation

extension String {
    func matches(fuzzy pattern: String) -> Bool {
        let patternTokens = Set(pattern.makeTokens())
        return patternTokens.first { token in self.contains(token) } != nil
    }
    
    func matches(tokens: [String]) -> Bool {
        tokens.first { token in self.contains(token) } != nil
    }
}
