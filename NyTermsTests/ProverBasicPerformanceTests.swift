//
//  ProverBasicPerformanceTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 01.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class ProverBasicPerformanceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        yices_init()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        yices_exit()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func _testPUZ001Yices() {
        let path = "PUZ001-1".p!
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = TrieProver(clauses: clauses)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        XCTAssertEqual(prover.run(Int.max),4)
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        
        
        let predicateSymbols = prover.symbols.keys { $0.1.type == SymbolType.Predicate }
        let expected = Set(["lives","killed","richer","hates"])
        XCTAssertEqual(Set(predicateSymbols),expected)
    }
    
    
    
    

}
