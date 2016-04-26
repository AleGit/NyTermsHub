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
    
    func testFileSize() {
        let path = "HWV134-1".p!
        let size = path.fileSize ?? -1
        XCTAssertEqual(276455091, size)
    }
    
    func testNoFileSize() {
        let path = "not/a/path/to/HWV134-1.p"
        XCTAssertNil(path.fileSize)
    }
    
    func testDirectoryFileSize() {
        let path = "/Users/Shared/"
        XCTAssertNil(path.fileSize)
    }
    
    func testParseInclude() {
        let string = "include('Axioms/SYN000-0.ax',[ia1,ia3])."
        let result = parse(string:string)
        XCTAssertEqual(2, result.formulae.count)
        XCTAssertEqual(0, result.status.first!)
        XCTAssertEqual(0, result.status.last!)
    }

    func testParseIncludeNoFile() {
        let string = "include('Axioms/SYN999-9.ax',[ia1,ia3])."
        let result = parse(string:string)
        XCTAssertEqual(0, result.formulae.count)
        XCTAssertEqual(0, result.status.first!)
        XCTAssertEqual(2, result.status.last!)
    }
    
    /// To succeed copy problem `SYN002-2.p` to `/Users/Shared/SampleA.p`
    ///
    ///    cp /Users/Shared/TPTP/Problems/SYN/SYN000-2.p /Users/Shared/SampleA.p
    func testPathSampleA() {
        let path = "/Users/Shared/SampleA.p"
        let result = parse(path:path)
        XCTAssertEqual(19, result.formulae.count)
        XCTAssertEqual(0, result.status.first!)
        XCTAssertEqual(0, result.status.last!)
        
    }
    
    /// To succeed copy axiom `SYN000-0.ax` to `/Users/Shared/AxiomB.ax`
    ///
    ///    cp /Users/Shared/TPTP/Axioms/SYN000-0.ax /Users/Shared/AxiomB.ax
    func testPathToAxiomB() {
        let path = "/Users/Shared/SampleA.p"
        let file = "AxiomB.ax"
        let expected = "/Users/Shared/AxiomB.ax"
        let actual = path.tptpPathTo(file)
        XCTAssertEqual(expected,actual)
        
        let result = parse(path:expected)
        XCTAssertEqual(3, result.formulae.count)
    }
    
    /// To succeed copy axiom `SYN000-0.ax` to `/Users/Shared/Axioms/AxiomC.ax`
    ///
    ///    mkdir /Users/Shared/Axioms
    ///    cp /Users/Shared/TPTP/Axioms/SYN000-0.ax /Users/Shared/Axioms/AxiomC.ax
    func testPathToAxiomC() {
        let path = "/Users/Shared/SampleA.p"
        let file = "Axioms/AxiomC.ax"
        let expected = "/Users/Shared/Axioms/AxiomC.ax"
        let actual = path.tptpPathTo(file)
        XCTAssertEqual(expected,actual)
        
        let result = parse(path:expected)
        XCTAssertEqual(3, result.formulae.count)
    }
    
    func testPathToSYN000() {
        let path = "/Users/Shared/SampleA.p"
        let file = "Axioms/SYN000-0.ax"
        let expected = TptpPath.tptpRootPath + "/" + "Axioms/SYN000-0.ax"
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
