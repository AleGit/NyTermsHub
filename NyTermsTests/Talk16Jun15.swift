//
//  Talk16Jun15.swift
//  NyTerms
//
//  Created by Alexander Maringele on 06.06.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class Talk16Jun15: XCTestCase {

    override func setUp() {
        super.setUp()
        Nylog.reset()
        resetGlobalStringSymbols()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        yices_init()
    }
    
    override func tearDown() {
        yices_exit()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPxNPy() {
        let clauses = [
            "p(X)|~p(Y)" as TptpNode,
            TptpNode(connective:"|", nodes:["p(a)"]),
            TptpNode(connective:"|", nodes:["~p(b)"])
        ]
        
        let prover = MingyProver(clauses: clauses)
        
        let (status,_,_) = prover.run(1.0)
        
        Nylog.printit()
        
        XCTAssertEqual(status, STATUS_UNSAT)
        
    }
    
    /// Since yices handles EUF correctly f(X)!=f(Y) is immediatyl proven inconsistent.
    func testFxNeqFy() {
        let clauses = [
            TptpNode(connective:"|", nodes:["f(X)!=f(Y)"]),
        ]
        
        let prover = MingyProver(clauses: clauses)
        
        let (status,_,_) = prover.run(1.0)
        
        Nylog.printit()
        
        XCTAssertEqual(status, STATUS_UNSAT)
        
    }
    
    func testFaNeqFb() {
        let clauses = [
            TptpNode(connective:"|", nodes:["f(a)!=f(b)"]),
            TptpNode(connective:"|", nodes:["X=Y"])
            ]
        
        let prover = MingyProver(clauses: clauses)
        
        let (status,_,_) = prover.run(1.0)
        
        Nylog.printit()
        
        XCTAssertEqual(status, STATUS_UNSAT)
        
    }

}
