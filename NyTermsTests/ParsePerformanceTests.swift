//
//  ParsePerformanceTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 09.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class ParsePerformanceTests: XCTestCase {
    var i = 0
    
    override func tearDown() {
        // Put teardown code here. 
        // This method is called after the invocation of each test method in the class.
        print("\(CFAbsoluteTimeGetCurrent())")
        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. 
        // This method is called before the invocation of each test method in the class.
        print("\(CFAbsoluteTimeGetCurrent())")
        i=1
    }
    
    /// ~1 ms on iMac24/7
    func testPerformanceLCL129cnf1() {
        let path = "/Users/Shared/TPTP/Problems/LCL/LCL129-1.p"
        self.measureBlock {
            print(CFAbsoluteTimeGetCurrent(), self.i++, path)
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(3, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
    
    /// < 32 ms on iMac24/7
    func testPerformancePUZ051cfn() {
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p"
        self.measureBlock {
            print(CFAbsoluteTimeGetCurrent(), self.i++, path)
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(2, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(0, result[1])
            XCTAssertEqual(43, tptpFormulae.count)
            XCTAssertEqual(1, tptpIncludes.count)
        }
    }
    
    /// < 3.2 s on iMac24/7
    func testPerformanceHWV074cnf1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV074-1.p"
        self.measureBlock {
            print(CFAbsoluteTimeGetCurrent(), self.i++, path)
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2581, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
    
    /// < 3.3 s on iMac24/7
    /// < 90 MB
    func testPerformanceHWV105cnf1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV105-1.p"
        self.measureBlock {
            print(CFAbsoluteTimeGetCurrent(), self.i++, path)
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(20_900, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
    
    /// < 5.9 s on iMac24/7;
    /// < 150 MB
    func testPerformanceHWV062fof1 () {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV062+1.p"
        
        self.measureBlock {
            print(CFAbsoluteTimeGetCurrent(), self.i++, path)
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
    
    /// < 123 s on iMac24/7;
    /// < 2.7 GB
    func testPerformanceHWV134fof1 () {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV134+1.p"
        
        self.measureBlock {
            print(CFAbsoluteTimeGetCurrent(), self.i++, path)
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(128_975, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }

    /// estimate: 600 s on iMac24/7, 400 s on Mm;
    /// < 10 GB
    func testPerformanceHWV134cnf1 () {
        let path = "/Users/Shared/TPTP/Problems/HHWV/HWV134-1.p"
        
        self.measureBlock {
            print(CFAbsoluteTimeGetCurrent(), self.i++, path)
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
}
