//
//  ProverBasicTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
import NyTerms

class YiProverBasicTests: XCTestCase {

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
    
    func testPropositionalTrue() {
        
        let wahr = "p|~p" as TestNode
        // let p = "p" as TestNode
        // let np = "~p" as TestNode
        let prover = YiProver(clauses: [wahr])
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        
    }
    
    func testPropositionalFalse() {
        let p = "p" as TestNode
        let np = "~p" as TestNode
        let prover = YiProver(clauses: [p,np])
        
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        
    }
    
    func testPUZ001() {
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p"
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        let tptpClauses = tptpFormulae.map { $0.root }
        
        let prover = YiProver(clauses: tptpClauses)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        
        
    }

}
