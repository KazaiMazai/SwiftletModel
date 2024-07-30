//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24/07/2024.
//

import Foundation

public extension Encodable  {
    func prettyDescription(with encoder: JSONEncoder) -> String? {
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

public extension JSONEncoder {
    static var prettyPrinting: JSONEncoder {
        let encoder = JSONEncoder()
        if #available(iOS 13.0, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        } else {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        
        return encoder
    }
}
