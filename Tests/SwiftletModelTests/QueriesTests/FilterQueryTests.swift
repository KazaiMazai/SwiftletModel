//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest

final class FilterQueryTests: XCTestCase {
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
    
    func test_WhenChainedFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter {
                $0.numOf1 == 1
                && $0.numOf10 == 2
            }
       
        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1, in: context)
            .filter(\.numOf10 == 2)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenAndPredicateFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter {
                $0.numOf1 == 1
                && $0.numOf10 == 2
            }
       
        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1, in: context)
            .filter(\.numOf10 == 2)
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenOrPredicateFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter {
                $0.numOf1 == 1
                || $0.numOf10 == 2
            }
       
        let context = context
        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1, in: context)
            .or(.filter(\.numOf10 == 2, in: context))
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
   
    func test_WhenComplexFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter {
                $0.numOf1 == 1
                ||  $0.numOf10 != 5
                || ($0.numOf1 > 1 && $0.numOf10 <= 4)
            }
        let context = context
        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1, in: context)
            .or(.filter(\.numOf10 != 5, in: context))
            .or(.filter(\.numOf1 > 1, in: context).and(\.numOf10 <= 4))
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenComplexFilterNotIndexed_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter {
                $0.numOf1 == 1
                || $0.numOf10 != 5
                || ($0.numOf1 > 1 && $0.numOf10 <= 4)
            }
        let context = context
        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1, in: context)
            .or(.filter(\.numOf10 != 5, in: context))
            .or(.filter(\.numOf1 > 1, in: context).and(\.numOf10 <= 4))
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenCompareComplexFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter {
                $0.numOf1 == 1
                ||  $0.numOf10 != 5
                || ($0.numOf1 >= 2 && $0.numOf10 < 4)
            }
        let context = context
        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1, in: context)
            .or(.filter(\.numOf10 != 5, in: context))
            .or(.filter(\.numOf1 >= 2, in: context).and(\.numOf10 < 4))
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
    
    func test_WhenCompareComplexFilterNotIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter {
                $0.numOf1 == 1
                ||  $0.numOf10 != 5
                || ($0.numOf1 >= 2 && $0.numOf10 < 4)
            }
        let context = context
        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1, in: context)
            .or(.filter(\.numOf10 != 5, in: context))
            .or(.filter(\.numOf1 >= 2, in: context).and(\.numOf10 < 4))
            .resolve()
        
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
}
