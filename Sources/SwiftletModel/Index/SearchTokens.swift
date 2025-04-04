//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 04/04/2025.
//

import Foundation
/*
public struct SearchTokens<Value> {
    let makeTokens: (Value) -> [Value]
    
    init(makeTokens: @escaping (Value) -> [Value]) {
        self.makeTokens = makeTokens
    }

    func makeTokens(for value: Value) -> [Value] {
        makeTokens(value)
    }
}

public extension SearchTokens where Value: Hashable {
    static var value: SearchTokens<Value> {
        SearchTokens { [$0] }
    }
}

public extension SearchTokens {
    static func && (lhs: SearchTokens<Value>, rhs: SearchTokens<Value>) -> SearchTokens<Value> {
        SearchTokens { value in
            lhs.makeTokens(value) + rhs.makeTokens(value)
        }
    }
}

public extension SearchTokens where Value == String {
    static var words: SearchTokens<String> {
        SearchTokens { text in
            text.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
                .map { String($0) }
        }
    }

    static func nGrams(of length: Int) -> SearchTokens<String> {
        SearchTokens { text in
            guard length > 0 else { return [] }
            return text
                .lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .flatMap { $0.windows(ofLength: length) }
                .map { String($0) }
        }
    }
}*/

extension String {
//    func searchTokens(with nGramLength: Int) -> [String] {
//        let words = self.words()
//        let nGrams = words
//            .flatMap { $0.windows(ofLength: nGramLength) }
//            .map { String($0) }
//
//        return words + nGrams
//    }
//    
//    func words() -> [String] {
//        self.lowercased()
//            .components(separatedBy: CharacterSet.alphanumerics.inverted)
//            .filter { !$0.isEmpty }
//            .map { String($0) }
//    }

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


extension Hashable where Self == String {
    func makeTokens() -> [Self] {
        self.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .map { String($0) }
    }
}
