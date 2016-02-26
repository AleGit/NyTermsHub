//
//  TptpPathTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 26.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class TptpPathTests: XCTestCase {

    func testTptpRootPath() {
        let supportedPaths = [ "/Users/Shared/TPTP", "/Users/Shared/TPTP-v6.3.0"]
        let actualRootPath = TptpPath.tptpRootPath
        XCTAssertTrue(supportedPaths.contains(actualRootPath),"\(actualRootPath) is not supported yet.")
    }
    
    func testAccessibleProblem() {
        XCTAssertNotNil("HWV001-1".p, "Problem file must be accessible.")
        XCTAssertNil("HWV999-9".p, "File must not exist.")
    }
    
    func testParseInclude() {
        let string = "include('Axioms/SYN000-0.ax',[ia1,ia3])."
        let result = parse(string:string)
        XCTAssertEqual(2, result.formulae.count)
        print(result)
    }

    func testParseIncludeNoFile() {
        let string = "include('Axioms/SYN999-9.ax',[ia1,ia3])."
        let result = parse(string:string)
        XCTAssertEqual(0, result.formulae.count)
        print(result)
    }
    
    func testPathSampleA() {
        let path = "/Users/Shared/SampleA.p"
        let result = parse(path:path)
        XCTAssertEqual(19, result.formulae.count)
        print(result)
        
    }
    
    func testPathToAxiomB() {
        let path = "/Users/Shared/SampleA.p"
        let file = "AxiomB.ax"
        let expected = "/Users/Shared/AxiomB.ax"
        let actual = path.tptpPathTo(file)
        XCTAssertEqual(expected,actual)
        
        let result = parse(path:expected)
        XCTAssertEqual(3, result.formulae.count)
    }
    
    func testPathToAxiomC() {
        let path = "/Users/Shared/SampleA.p"
        let file = "Axioms/AxiomC.ax"
        let expected = "/Users/Shared/Axioms/AxiomC.ax"
        let actual = path.tptpPathTo(file)
        XCTAssertEqual(expected,actual)
        
        let result = parse(path:expected)
        XCTAssertEqual(3, result.formulae.count)
    }
    
    func testPathToAxiomS() {
        
        let path = "/Users/Shared/SampleA.p"
        let file = "Axioms/SYN000-0.ax"
        let expected = TptpPath.tptpRootPath + "/Axioms/SYN000-0.ax"
        let actual = path.tptpPathTo(file)
        XCTAssertEqual(expected,actual)
        
        let result = parse(path:expected)
        XCTAssertEqual(3, result.formulae.count)
    }
    
    func testPathToAxiomX() {
        let path = "/Users/Shared/SampleA.p"
        let file = "AxiomX.ax"
        let actual = path.tptpPathTo(file)
        XCTAssertNil(actual)
    }

}
