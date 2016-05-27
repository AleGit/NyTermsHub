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
        Nylog.printit()
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
        let empty = TestNode(connective:"|",nodes: [TestNode]())
        
        let prover = MingyProver(clauses: [empty])
        let (result,runtime) = measure { prover.run(1.0) }
        print("runtime",result,runtime)
        
        XCTAssertEqual(STATUS_UNSAT, result.0)
        XCTAssertEqual(false, result.1)
    }

    func testPropositionalFalse() {
        let p = TestNode(connective:"|", nodes:[ "p" as TestNode])
        let np = TestNode(connective:"|", nodes:[ "~p" as TestNode])
        
        let prover = MingyProver(clauses: [p,np])
        let (result,runtime) = measure { prover.run(1.0) }
        print("runtime",result,runtime)
        
        XCTAssertEqual(STATUS_UNSAT, result.0)
        XCTAssertEqual(false, result.1)
    }

    func testPropositionalSatisfiable() {
        let satisfiable = TestNode(connective:"|",nodes:["p"])
        
        let prover = MingyProver(clauses: [satisfiable])
        let (result,runtime) = measure { prover.run(1.0) }
        print("runtime",result,runtime)
        
        XCTAssertEqual(STATUS_SAT, result.0)
        XCTAssertEqual(false, result.1)
    }

    func testPUZ001() {
        let path = "PUZ001-1".p!
        
        let (parseResult,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, parseResult.count)
        XCTAssertEqual(0, parseResult[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = MingyProver(clauses: clauses)
        let (result,runtime) = measure { prover.run(30.0) }
        print("+++ total runtime",result,runtime)
        
        XCTAssertEqual(STATUS_UNSAT, result.0)
        XCTAssertEqual(false, result.1)
    }
    
    func testPUZ002() {
        let path = "PUZ002-1".p!
        
        let (parseResult,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, parseResult.count)
        XCTAssertEqual(0, parseResult[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = MingyProver(clauses: clauses)
        let (result,runtime) = measure { prover.run(30.0) }
        print("+++ total runtime",result,runtime)
        
        XCTAssertEqual(STATUS_UNSAT, result.0)
        XCTAssertEqual(false, result.1)
    }
    
    func testPUZ003() {
        let path = "PUZ003-1".p!
        
        let (parseResult,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, parseResult.count)
        XCTAssertEqual(0, parseResult[0])
        XCTAssertEqual(8, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = MingyProver(clauses: clauses)
        let (result,runtime) = measure { prover.run(30.0) }
        print("+++ total runtime",result,runtime)
        
        XCTAssertEqual(STATUS_UNSAT, result.0)
        XCTAssertEqual(false, result.1)
    }
//    
//    /// see **Example 3.7** in [AlM2014SR]
//    func testInfiniteDomain() {
//        let clauses : [TestNode] = [
//            TestNode(connective:"|", nodes: ["~(p(X,X))"]),
//            TestNode(connective:"|", nodes: ["p(X,f(X))"]),
//            "~(p(X,Y))|~(p(Y,Z))|p(X,Z)"
//        ]
//        
//        let prover = MingyProver(clauses: clauses)
//        let (status,runtime) = measure { prover.run() }
//        print("runtime",runtime)
//        XCTAssertEqual(STATUS_SAT, status)
//        
//    }

}
