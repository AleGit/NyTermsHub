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
    var t0 = 0.0
    var ti = 0.0
    
    override func tearDown() {
        // Put teardown code here. 
        // This method is called after the invocation of each test method in the class.
        print(self.runtime)
        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. 
        // This method is called before the invocation of each test method in the class.
        i=1
        t0 = CFAbsoluteTimeGetCurrent()
        ti = CFAbsoluteTimeGetCurrent()
    }
    
    var runtime: String {
        
        let now = CFAbsoluteTimeGetCurrent()
        let rt = (now-ti).timeIntervalDescriptionMarkedWithUnits
        ti = now
        return rt
    
    }
    
    
    
    
    /// ~ 1.2 ms on iMac24/7
    func testPerformanceLCL129cnf1() {
        let path = "LCL129-1".p         // 2.1K
        self.measureBlock {
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(3, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
    
    /// ~ 3 ms on iMac24/7
    func testPerformanceSYN000cnf2() {
        let path = "SYN000-2".p         // 3.0K
        
        self.measureBlock {
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
            XCTAssertEqual(2, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(0, result[1])
            XCTAssertEqual(19, tptpFormulae.count)
            XCTAssertEqual(1, tptpIncludes.count)
        }
    }
    
    ///  32 ms on iMac24/7
    func testPerformancePUZ051cfn() {
        let path = "PUZ051-1".p         // 1.9K
        self.measureBlock {
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
            XCTAssertEqual(2, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(0, result[1])
            XCTAssertEqual(43, tptpFormulae.count)
            XCTAssertEqual(1, tptpIncludes.count)
        }
    }
    
    /// ~ 3.3 s on iMac24/7
    func testPerformanceHWV074cnf1() {
        let path = "HWV074-1".p         // 996K
        self.measureBlock {
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2581, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
    
    /// ~ 3.4 s on iMac24/7
    /// < 90 MB
    func testPerformanceHWV105cnf1() {
        let path = "HWV105-1".p         // 2.0M
        self.measureBlock {
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(20_900, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
    
    /// ~ 5.9 s on iMac24/7;
    /// < 150 MB
    func testPerformanceHWV062fof1 () {
        let path = "HWV062+1".p         // 2.0M
        
        self.measureBlock {
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
    
    /// < 123 s on iMac24/7;
    /// < 2.7 GB
    func testPerformanceHWV134fof1 () {
        let path = "HWV134+1".p         // 84 M
        
        self.measureBlock {
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(128_975, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }

    /// estimate: 600 s on iMac24/7, 
    /// 262 s on Mm;
    /// < 10 GB
    func testPerformanceHWV134cnf1 () {
        let path = "HWV134-1".p         // 264M
        
        self.measureBlock {
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2_332_428, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
}
