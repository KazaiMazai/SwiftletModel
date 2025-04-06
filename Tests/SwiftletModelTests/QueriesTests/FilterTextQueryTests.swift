//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest

final class FilterTextQueryTests: XCTestCase {
    var context = Context()
    
    lazy var notIndexedModels = {
        TestingModels.StringNotIndexed.shuffled()
    }()

    lazy var indexedModels = {
        TestingModels.StringFullTextIndexed.shuffled()
    }()
    
    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }
        
        try indexedModels
            .forEach { try $0.save(to: &context) }
    }
    
    func test_WhenContainsFilterNoIndex_ThenEqualPlainFitlering() throws {
        let expected = notIndexedModels
            .filter { $0.text.contains("ananas") }
       
        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, contains: "ananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenContainsFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { $0.text.contains("ananas") }
       
        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, contains: "ananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenPrefixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { $0.text.hasPrefix("bananas") }
       
        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, hasPrefix: "bananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenPrefixFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { $0.text.starts(with: "bananas") }
       
        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, hasPrefix: "bananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenSuffixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { $0.text.hasSuffix("bananas") }
       
        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, hasSuffix: "bananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenSuffixFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { $0.text.hasSuffix("bananas") }
       
        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, hasSuffix: "bananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenNotHavingPrefixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { !$0.text.hasPrefix("bananas") }
       
        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, notHavingPrefix: "bananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenNotHavingPrefixFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { !$0.text.starts(with: "bananas") }
       
        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, notHavingPrefix: "bananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenNotHavingSuffixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { !$0.text.hasSuffix("bananas") }
       
        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, notHavingSuffix: "bananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenNotHavingSuffixFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { !$0.text.hasSuffix("bananas") }
       
        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, notHavingSuffix: "bananas"), in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

}
