//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest

class FilterQueryTests: XCTestCase {
    let count = 100
    var context = Context()
    
    lazy var notIndexedModels = {
        TestingModels.NotIndexed.shuffled(count)
    }()

    lazy var indexedModels = {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }()
    
    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }
        
        try indexedModels
            .forEach { try $0.save(to: &context) }
    }
    
    func test_WhenFilterNoIndex_ThenEqualPlainFitlering() throws {
        let expected = notIndexedModels
            .filter { $0.numOf1 == 1 }
       
        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1, in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter { $0.numOf1 == 1 }
       
        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1, in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
}

class FilterByTwoPathQueryTests: XCTestCase {
    let count = 100
    var context = Context()
    
    lazy var notIndexedModels = {
        TestingModels.NotIndexed.shuffled(count)
    }()

    lazy var indexedModels = {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }()
    
    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }
        
        try indexedModels
            .forEach { try $0.save(to: &context) }
    }
    
    func test_WhenFilterNoIndex_ThenEqualPlainFitlering() throws {
        let expected = notIndexedModels
            .filter { $0.numOf1 == 1 }
       
        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1, in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter { $0.numOf1 == 1 }
       
        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1, in: context)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
}
