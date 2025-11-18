//
//  ArrayExtensionsTests.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 17/11/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest

final class ArrayExtensionsTests: XCTestCase {

    // MARK: - removingDuplicates(by:) tests

    func test_removingDuplicates_WhenArrayIsEmpty_ThenReturnsEmptyArray() {
        let emptyArray: [Int] = []
        let result = emptyArray.removingDuplicates(by: { $0 })

        XCTAssertEqual(result, [])
    }

    func test_removingDuplicates_WhenArrayHasNoDuplicates_ThenReturnsOriginalArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.removingDuplicates(by: { $0 })

        XCTAssertEqual(result, [1, 2, 3, 4, 5])
    }

    func test_removingDuplicates_WhenArrayHasDuplicates_ThenReturnsDeduplicated() {
        let array = [1, 2, 3, 2, 4, 3, 5]
        let result = array.removingDuplicates(by: { $0 })

        XCTAssertEqual(result, [1, 2, 3, 4, 5])
    }

    func test_removingDuplicates_WhenArrayHasAllDuplicates_ThenReturnsSingleElement() {
        let array = [1, 1, 1, 1, 1]
        let result = array.removingDuplicates(by: { $0 })

        XCTAssertEqual(result, [1])
    }

    func test_removingDuplicates_WhenArrayHasSingleElement_ThenReturnsSingleElement() {
        let array = [42]
        let result = array.removingDuplicates(by: { $0 })

        XCTAssertEqual(result, [42])
    }

    func test_removingDuplicates_WhenRemovingDuplicates_ThenPreservesFirstOccurrence() {
        let array = [1, 2, 3, 2, 4, 3, 5, 1]
        let result = array.removingDuplicates(by: { $0 })

        XCTAssertEqual(result, [1, 2, 3, 4, 5])
    }

    func test_removingDuplicates_WhenUsingCustomKey_ThenDeduplicatesByKey() {
        struct Person {
            let id: Int
            let name: String
        }

        let people = [
            Person(id: 1, name: "Alice"),
            Person(id: 2, name: "Bob"),
            Person(id: 1, name: "Alice Updated"),
            Person(id: 3, name: "Charlie")
        ]

        let result = people.removingDuplicates(by: { $0.id })

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].name, "Alice")
        XCTAssertEqual(result[1].id, 2)
        XCTAssertEqual(result[2].id, 3)
    }

    func test_removingDuplicates_WhenUsingStringKey_ThenDeduplicatesByString() {
        let array = ["apple", "banana", "apple", "cherry", "banana", "date"]
        let result = array.removingDuplicates(by: { $0 })

        XCTAssertEqual(result, ["apple", "banana", "cherry", "date"])
    }

    // MARK: - limit(_:offset:) tests

    func test_limit_WhenArrayIsEmpty_ThenReturnsEmptyArray() {
        let emptyArray: [Int] = []
        let result = emptyArray.limit(5, offset: 0)

        XCTAssertEqual(result, [])
    }

    func test_limit_WhenOffsetIsZero_ThenReturnsFirstElements() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let result = array.limit(3, offset: 0)

        XCTAssertEqual(result, [1, 2, 3])
    }

    func test_limit_WhenOffsetIsNonZero_ThenReturnsElementsFromOffset() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let result = array.limit(3, offset: 5)

        XCTAssertEqual(result, [6, 7, 8])
    }

    func test_limit_WhenLimitExceedsRemainingElements_ThenReturnsRemainingElements() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(10, offset: 2)

        XCTAssertEqual(result, [3, 4, 5])
    }

    func test_limit_WhenOffsetIsAtEnd_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(3, offset: 5)

        XCTAssertEqual(result, [])
    }

    func test_limit_WhenOffsetExceedsArrayLength_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(3, offset: 10)

        XCTAssertEqual(result, [])
    }

    func test_limit_WhenLimitIsZero_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(0, offset: 0)

        XCTAssertEqual(result, [])
    }

    func test_limit_WhenLimitIsNegative_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(-5, offset: 0)

        XCTAssertEqual(result, [])
    }

    func test_limit_WhenOffsetIsNegative_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(3, offset: -1)

        XCTAssertEqual(result, [])
    }

    func test_limit_WhenLimitIsOne_ThenReturnsSingleElement() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(1, offset: 2)

        XCTAssertEqual(result, [3])
    }

    func test_limit_WhenArrayHasSingleElement_ThenReturnsThatElement() {
        let array = [42]
        let result = array.limit(5, offset: 0)

        XCTAssertEqual(result, [42])
    }

    func test_limit_WhenOffsetAndLimitCoverEntireArray_ThenReturnsEntireArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(5, offset: 0)

        XCTAssertEqual(result, [1, 2, 3, 4, 5])
    }

    func test_limit_WhenUsingStringArray_ThenWorksCorrectly() {
        let array = ["a", "b", "c", "d", "e", "f"]
        let result = array.limit(2, offset: 3)

        XCTAssertEqual(result, ["d", "e"])
    }

    func test_limit_WhenCalledMultipleTimes_ThenProducesConsistentResults() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        let result1 = array.limit(3, offset: 4)
        let result2 = array.limit(3, offset: 4)

        XCTAssertEqual(result1, result2)
        XCTAssertEqual(result1, [5, 6, 7])
    }

    func test_limit_WhenChaining_ThenWorksCorrectly() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        let result = array.limit(6, offset: 2).limit(2, offset: 1)

        XCTAssertEqual(result, [4, 5])
    }
}
