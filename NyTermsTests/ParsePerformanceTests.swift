//
//  ParsePerformanceTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 09.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

extension CFAbsoluteTime {
    static let hour = 3600.0
    static let minute = 60.0
    static let second = 1.0
    static let ms = 0.001
    static let µs = 0.000_001
    static let ns = 0.000_000_001
    static let units = [
        hour : "h",
        minute : "m",
        second : "s",
        ms: "ms",
        µs : "µs",
        ns : "ns"
    ]
    
    var niceTimeDescription : String {
        var t = self
        switch self {
        case _ where floor(t/CFAbsoluteTime.hour) > 0:
            t += 0.5*CFAbsoluteTime.minute // round minute
            let hour = t/CFAbsoluteTime.hour
            t -= floor(hour)*CFAbsoluteTime.hour
            let minute = t/CFAbsoluteTime.minute
            return "\(Int(hour))\(CFAbsoluteTime.units[CFAbsoluteTime.hour]!)" + " \(Int(minute))\(CFAbsoluteTime.units[CFAbsoluteTime.minute]!)"
            
        case _ where floor(t/CFAbsoluteTime.minute) > 0:
            t += 0.5*CFAbsoluteTime.second // round second
            let minute = t/CFAbsoluteTime.minute
            t -= floor(minute)*CFAbsoluteTime.minute
            let second = t/CFAbsoluteTime.second
            return "\(Int(minute))\(CFAbsoluteTime.units[CFAbsoluteTime.minute]!)" + " \(Int(second))\(CFAbsoluteTime.units[CFAbsoluteTime.second]!)"
            
        case _ where floor(t/CFAbsoluteTime.second) > 0:
            t += 0.5*CFAbsoluteTime.ms // round ms
            let second = t/CFAbsoluteTime.second
            t -= floor(second)*CFAbsoluteTime.second
            let ms = t/CFAbsoluteTime.ms
            return "\(Int(second))\(CFAbsoluteTime.units[CFAbsoluteTime.second]!)" + " \(Int(ms))\(CFAbsoluteTime.units[CFAbsoluteTime.ms]!)"
            
        case _ where floor(t/CFAbsoluteTime.ms) > 0:
            t += 0.5*CFAbsoluteTime.µs // round µs
            let ms = t/CFAbsoluteTime.ms
            t -= floor(ms)*CFAbsoluteTime.ms
            let µs = t/CFAbsoluteTime.µs
            return "\(Int(ms))\(CFAbsoluteTime.units[CFAbsoluteTime.ms]!)" + " \(Int(µs))\(CFAbsoluteTime.units[CFAbsoluteTime.µs]!)"
            
        case _ where floor(t/CFAbsoluteTime.µs) > 0:
            t += 0.5*CFAbsoluteTime.ns // round µs
            let µs = t/CFAbsoluteTime.µs
            t -= floor(µs)*CFAbsoluteTime.µs
            let ns = t/CFAbsoluteTime.ns
            return "\(Int(µs))\(CFAbsoluteTime.units[CFAbsoluteTime.µs]!)" + " \(Int(ns))\(CFAbsoluteTime.units[CFAbsoluteTime.ns]!)"
            
        default:
            let ns = t/CFAbsoluteTime.ns
            return "\(ns)\(CFAbsoluteTime.units[CFAbsoluteTime.ns]!)"
            
        }
    }
}

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
        let rt = (now-ti).niceTimeDescription
        ti = now
        return rt
    
    }
    
    
    
    
    /// ~ 1.2 ms on iMac24/7
    func testPerformanceLCL129cnf1() {
        let path = "/Users/Shared/TPTP/Problems/LCL/LCL129-1.p"
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
        let path = "/Users/Shared/TPTP/Problems/SYN/SYN000-2.p"
        
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
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p"
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
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV074-1.p"
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
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV105-1.p"
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
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV062+1.p"
        
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
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV134+1.p"
        
        self.measureBlock {
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
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
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            print(self.runtime, self.i++, path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
}
