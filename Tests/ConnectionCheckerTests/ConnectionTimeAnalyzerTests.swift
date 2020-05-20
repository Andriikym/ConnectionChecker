/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import XCTest
@testable import ConnectionChecker

class ConnectionTimeAnalyzerTests: XCTestCase {
    let excellentBorder = 0.25
    let goodBorder = 0.5
    let poorBorder = 1.5
    
    var sut: ConnectionTimeAnalyzer!
    var input: [CFAbsoluteTime?]!
    var result: ConnectionQuality?
    
    override func setUp() {
        sut = ConnectionTimeAnalyzer()
    }

    override func tearDown() {
        input = nil
        result = nil
        sut = nil
    }

    func testAbsentQualityAnalyze() {
        input = [nil, nil]
        result = sut.analyze(input)
        XCTAssertEqual(result, .absent, "Should have absent result")
    }

    func testNoInputAnalyze() {
        input = []
        result = sut.analyze(input)
        XCTAssertEqual(result, .absent, "Should have absent result")
    }
    
    func testLostPacketsQualityAnalyze() {
        input = [excellentBorder, nil, excellentBorder]
        result = sut.analyze(input)
        XCTAssertEqual(result, .poor, "Should have poor result")
    }

    func testPoorQualityAnalyze() {
        input = [excellentBorder - 0.4, excellentBorder, poorBorder + 0.01]
        result = sut.analyze(input)
        XCTAssertEqual(result, .poor, "Should have poor result")
    }
    
    func testSlowQualityAnalyze() {
        input = [excellentBorder + 0.01, excellentBorder - 0.01, poorBorder]
        result = sut.analyze(input)
        XCTAssertEqual(result, .slow, "Should have slow result")
    }
    
    func testBarelySlowQualityAnalyze() {
        input = [excellentBorder + 0.01, excellentBorder - 0.01, goodBorder + 0.01]
        result = sut.analyze(input)
        XCTAssertEqual(result, .slow, "Should have slow result")
    }
    
    func testGoodQualityAnalyze() {
        input = [excellentBorder + 0.01, excellentBorder - 0.01, excellentBorder]
        result = sut.analyze(input)
        XCTAssertEqual(result, .good, "Should have good result")
    }
    
    func testBarelyGoodQualityAnalyze() {
        input = [excellentBorder + 0.01, goodBorder - 0.01, goodBorder]
        result = sut.analyze(input)
        XCTAssertEqual(result, .good, "Should have good result")
    }
    
    func testExcellentQualityAnalyze() {
        input = [excellentBorder, excellentBorder - 0.5, excellentBorder - 0.01]
        result = sut.analyze(input)
        XCTAssertEqual(result, .excellent, "Should have excellent result")
    }
}
