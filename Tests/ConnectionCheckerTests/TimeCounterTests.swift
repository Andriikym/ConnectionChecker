/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import XCTest
@testable import ConnectionChecker

class TimeCounterTests: XCTestCase {
    var sut: TimeMeasurer?

    override func setUp() {
        sut = TimeMeasurer(timeProvider: 2)
    }

    override func tearDown() {
        sut = nil
    }

    func testMeasure() {
        sut?.timeProvider = { 5 }
        let result = sut?.measure()
        XCTAssertEqual(result, 3, "Should have correct result") // Starts at 2, measured at 5, result 3
    }
    
    func testRepeatedMeasure() {
        sut?.timeProvider = { 5 }
        let result = sut?.measure()
        sut?.timeProvider = { 10 }
        let newResult = sut?.measure()
        XCTAssertEqual(result, newResult, "Result should not change from the first measure")
    }
}
