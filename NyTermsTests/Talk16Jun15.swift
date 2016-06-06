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
    
    func testUnifier() {
        
        let l1 = "p(X,X)" as TptpNode
        let l2 = "p(Y,f(Y))" as TptpNode
        let l3 = "p(Z1,Z2)" as TptpNode

        
        XCTAssertNil(l1 =?= l2, "\n\(l1) =?= \(l2) = \(l1 =?= l2)")
        XCTAssertNil(l2 =?= l1, "\n\(l2) =?= \(l1) = \(l2 =?= l1)")
        
        let mgu23 = (l2 =?= l3)!
        XCTAssertEqual(l2 * mgu23, l3*mgu23, "\n\(l2) =?= \(l3) = \(mgu23)")
        
        let mgu32 = (l3 =?= l2)!
        XCTAssertEqual(l2 * mgu32, l3*mgu32, "\n\(l3) =?= \(l2) = \(mgu32)")
        

    }

}
