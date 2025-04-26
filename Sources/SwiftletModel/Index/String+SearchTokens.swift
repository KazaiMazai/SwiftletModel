//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 05/04/2025.
//

import Foundation

extension String {
    func makeTokens() -> [String] {
        self.nGrams(of: 3)
    }
}

extension String {
    func nGrams(of length: Int) -> [String] {
        guard length > 0 else { return [] }
        return self
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .flatMap { $0.windows(ofLength: length) }
            .map { String($0) }
    }

    func windows(ofLength length: Int) -> [SubSequence] {
        guard length > 0 else {
            return []
        }

        guard self.count >= length else {
            return []
        }

        return (0...(self.count - length))
            .map { start in
                let end = start + length
                return self[index(startIndex, offsetBy: start)..<index(startIndex, offsetBy: end)]
            }
    }
}
