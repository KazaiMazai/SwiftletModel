//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest

class FilterByOnePathQueryPerformanceTests: XCTestCase {
    let count = 3000
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
    
    func test_NoIndex_FilterPerformance() throws {
        measure {
            let _ = TestingModels.NotIndexed
                .filter(\.numOf1 == 1, in: context)
                .and {
                    $0.filter(\.numOf1 == 10)
                      .or { $0.filter(\.numOf1 == 10) }
                }
                .resolve()
        }
    }
    
    func test_Indexed_FilterPerformance() throws {
        measure {
            let _ = TestingModels.ExtensivelyIndexed
                .filter(\.numOf1 == 1, in: context)
                .resolve()
        }
    }
}
 
