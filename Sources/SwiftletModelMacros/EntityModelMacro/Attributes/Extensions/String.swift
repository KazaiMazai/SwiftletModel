//
//  String.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 06/11/2025.
//

import Foundation

extension String {
    func cleanedKeyPath() -> String {
        replacingOccurrences(of: "\\", with: "")
    }
}
