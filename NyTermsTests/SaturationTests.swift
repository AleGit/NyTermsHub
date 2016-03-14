//
//  SaturationTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class SaturationTests: XCTestCase {
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
    
    /// unsatisfiable PUZ011-1 saturates 
    func testPUZ011m1() {
        let name = "PUZ021-1"
        guard let path = name.p else {
            XCTFail("Did not find \(name).p")
            return
        }
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(13, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = TrieProver(clauses: clauses)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        let (rounds,runtime) = prover.run()
        print("rounds:", rounds, "• runtime:",runtime.prettyTimeIntervalDescription)
        XCTAssertEqual(STATUS_UNSAT, prover.status)
    }

    
}
