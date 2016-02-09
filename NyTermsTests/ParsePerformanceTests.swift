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

    func testPerformanceExample() {
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p"
        self.measureBlock {
            
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(2, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(0, result[1])
            XCTAssertEqual(43, tptpFormulae.count)
            XCTAssertEqual(1, tptpIncludes.count)
        }
    }
    
    func testPerformanceHWV105cnf1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV105-1.p"
        self.measureBlock {
            
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(20_900, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }
    
    func testPerformanceHWV074cnf1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV074-1.p"
        self.measureBlock {
            
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2581, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
        }
    }

}
