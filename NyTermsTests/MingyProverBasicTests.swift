////
////  MingyProverBasicTests.swift
////  NyTerms
////
////  Created by Alexander Maringele on 04.03.16.
////  Copyright © 2016 Alexander Maringele. All rights reserved.
////

import XCTest
@testable import NyTerms

class MingyProverBasicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        yices_init()
        Nylog.reset()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        Nylog.printparts()
        yices_exit()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPropositionalTrue() {
        let wahr = "p|~p" as TestNode
        
        let prover = MingyProver(clauses: [wahr])
        let (result,runtime) = measure { prover.run(0.1) }
        print("runtime",result,runtime)

        XCTAssertEqual(STATUS_SAT, result.0)
        XCTAssertEqual(false, result.1)
    }

    func testEmptyClause() {
        let empty = TestNode(symbol:"|",nodes: [TestNode]())
        
        let prover = MingyProver(clauses: [empty])
        let (result,runtime) = measure { prover.run(1.0) }
        print("runtime",result,runtime)
        
        XCTAssertEqual(STATUS_UNSAT, result.0)
        XCTAssertEqual(false, result.1)
    }

    func testPropositionalFalse() {
        let p = TestNode(symbol:"|", nodes:[ "p" as TestNode])
        let np = TestNode(symbol:"|", nodes:[ "~p" as TestNode])
        
        let prover = MingyProver(clauses: [p,np])
        let (result,runtime) = measure { prover.run(1.0) }
        print("runtime",result,runtime)
        
        XCTAssertEqual(STATUS_UNSAT, result.0)
        XCTAssertEqual(false, result.1)
    }

    func testPropositionalSatisfiable() {
        let satisfiable = TestNode(symbol:"|",nodes:["p"])
        
        let prover = MingyProver(clauses: [satisfiable])
        let (result,runtime) = measure { prover.run(1.0) }
        print("runtime",result,runtime)
        
        XCTAssertEqual(STATUS_SAT, result.0)
        XCTAssertEqual(false, result.1)
    }

    func testEasyPuzzles() {
        for (name,count) in [
            ("PUZ001-1",12),
            ("PUZ002-1",12),
            ("PUZ003-1",8),
            ("PUZ004-1",12),
            ] {
        
        guard let path = name.p else {
            XCTFail("\(name) was not found.")
            continue
        }
        
        let (parseResult,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, parseResult.count)
        XCTAssertEqual(0, parseResult[0])
        XCTAssertEqual(count, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = MingyProver(clauses: clauses)
        let (result,runtime) = measure { prover.run(30.0) }
        print("+++ \(path) +++ total runtime",result,runtime)
        
        XCTAssertEqual(STATUS_UNSAT, result.0)
        XCTAssertFalse(result.1) // no timeout!
        }
    }
    
    /// see **Example 3.7** in [AlM2014SR]
    func testInfiniteDomain() {
        let clauses : [TestNode] = [
            // TestNode(connective:"|", nodes: ["p(X,X)"]),
            //TestNode(connective:"|", nodes: ["~(p(X,f(X)))"]),
            // "p(X,Y)|~p(f(X),f(Y))"
            TestNode(symbol:"|", nodes: ["X!=f(X)"]),
            "X=Y|f(X)!=f(Y)"
            
        ]
        
        let prover = MingyProver(clauses: clauses)
        let (result,runtime) = measure { prover.run(0.1) }
        print("runtime",runtime)
        XCTAssertEqual(STATUS_SAT, result.0)
        XCTAssertTrue(result.1) // timeout!
        
    }

}
