//
//  ProverBasicTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
@testable
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
        let prover = YiProver(clauses: [wahr])
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        XCTAssertEqual(prover.run(Int.max),1)
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        let predicateSymbols = prover.symbols.filteredSetOfKeys { $0.1.type == SymbolType.Predicate }
        let expected = Set(["p"])
        XCTAssertEqual(predicateSymbols,expected)
    }
    
    func testEmptyClause() {
        let empty = TestNode(connective:"|",nodes: [TestNode]())
        
        let prover = YiProver(clauses: [empty])
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        XCTAssertEqual(prover.run(Int.max),0)
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        
        let predicateSymbols = prover.symbols.filteredSetOfKeys { $0.1.type == SymbolType.Predicate }
        let expected = Set<String>()
        XCTAssertEqual(predicateSymbols,expected)
    }
    
    func testPropositionalFalse() {
        let p = "p" as TestNode
        let np = "~p" as TestNode
        let prover = YiProver(clauses: [p,np])
        
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        XCTAssertEqual(prover.run(Int.max),0)
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        
        let predicateSymbols = prover.symbols.filteredSetOfKeys { $0.1.type == SymbolType.Predicate }
        let expected = Set(["p"])
        XCTAssertEqual(predicateSymbols,expected)

    }
    
    func testPropositionalSatisfiable() {
        
        let satisfiable = "p" as TestNode
        let prover = YiProver(clauses: [satisfiable])
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        XCTAssertEqual(prover.run(Int.max),1)
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        let predicateSymbols = prover.symbols.filteredSetOfKeys { $0.1.type == SymbolType.Predicate }
        let expected = Set(["p"])
        XCTAssertEqual(predicateSymbols,expected)
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
        XCTAssertEqual(prover.run(Int.max),4)
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        
        
        let predicateSymbols = prover.symbols.filteredSetOfKeys { $0.1.type == SymbolType.Predicate }
        let expected = Set(["lives","killed","richer","hates"])
        XCTAssertEqual(predicateSymbols,expected)
    }
    
    func testSYO587m1() {
        let path = "/Users/Shared/TPTP/Problems/SYO/SYO587-1.p"
        
        let start = CFAbsoluteTimeGetCurrent()
        
        let (result,tptpFormulae,_) = parse(path:path)
        var times = [("parsed",CFAbsoluteTimeGetCurrent()-start)]
        print(times.last!)

        
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(19862, tptpFormulae.count)
        times.append(("check 0",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        
        let tptpClauses = tptpFormulae.map { $0.root }
        times.append(("mapped",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        
        
        let prover = YiProver(clauses: tptpClauses)
        times.append(("prover",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        times.append(("check 1",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        XCTAssertEqual(prover.run(1),2)
        times.append(("run(1)",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        // XCTAssertEqual(STATUS_UNSAT, prover.status)
        times.append(("check 2",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        
        
        let predicateSymbols = prover.symbols.filteredSetOfKeys { $0.1.type == SymbolType.Predicate }
        XCTAssertEqual(predicateSymbols.count,4480)
    }
    
    
   

    func testPUZ056m2_030() {
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ056-2.030.p"
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(41, tptpFormulae.count)
        
        let tptpClauses = tptpFormulae.map { $0.root }
        
        let prover = YiProver(clauses: tptpClauses)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        prover.run(1)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
    }
    
    
    /// satisfiable, hence the saturation process must be optimized
    func _testPUZ028m3() {
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ028-3.p"
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(504, tptpFormulae.count)
        
        let tptpClauses = tptpFormulae.map { $0.root }
        
        let prover = YiProver(clauses: tptpClauses)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        prover.run(1)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        
        
    }
    
    /// see **Example 3.7** in [AlM2014SR]
    func testInfiniteDomain() {
        let clauses : [TestNode] = [
            TestNode(connective:"|", nodes: ["~(p(X,X))"]),
            TestNode(connective:"|", nodes: ["p(X,f(X))"]),
            "~(p(X,Y))|~(p(Y,Z))|p(X,Z)"
        ]
        
        XCTAssertTrue(clauses[0].isClause)
        XCTAssertTrue(clauses[0].isClause)
        XCTAssertTrue(clauses[2].isClause)
        XCTAssertTrue(clauses[2].nodes?.count == 3)
        
        let prover = YiProver(clauses: clauses)
        
        prover.run(4)
         XCTAssertEqual(STATUS_SAT, prover.status)
        
    }

}
