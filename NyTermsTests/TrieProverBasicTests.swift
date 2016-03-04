//
//  TrieProverBasicTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 01.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class TrieProverBasicTests: XCTestCase {
    typealias TheProver = TrieProver<TestNode>
    
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
        let prover = TheProver(clauses: [wahr])
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        let runResult = prover.run()
        XCTAssertEqual(runResult.0, 1)
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        let predicateSymbols = prover.symbols.keys { $0.1.type == SymbolType.Predicate }
        let expected = ["p"]
        XCTAssertEqual(predicateSymbols,expected)
    }
    
    func testEmptyClause() {
        let empty = TestNode(connective:"|",nodes: [TestNode]())
        
        let prover = TheProver(clauses: [empty])
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        let runResult = prover.run()
        XCTAssertEqual(runResult.0, 1)
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        
        let predicateSymbols = prover.symbols.keys { $0.1.type == SymbolType.Predicate }
        let expected = [String]()
        XCTAssertEqual(predicateSymbols,expected)
    }
    
    func testPropositionalFalse() {
        let p = "p" as TestNode
        let np = "~p" as TestNode
        let prover = TheProver(clauses: [p,np])
        
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        let runResult = prover.run()
        XCTAssertEqual(runResult.0, 1)
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        
        let predicateSymbols = prover.symbols.keys { $0.1.type == SymbolType.Predicate }
        let expected = ["p"]
        XCTAssertEqual(predicateSymbols,expected)
        
    }
    
    func testPropositionalSatisfiable() {
        
        let satisfiable = "p" as TestNode
        let prover = TheProver(clauses: [satisfiable])
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        let runResult = prover.run()
        XCTAssertEqual(runResult.0, 1)
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        let predicateSymbols = prover.symbols.keys { $0.1.type == SymbolType.Predicate }
        let expected = ["p"]
        XCTAssertEqual(predicateSymbols,expected)
    }
    
    func testPUZ001() {
        let path = "PUZ001-1".p!
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = TheProver(clauses: clauses)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        let runResult = prover.run()
        XCTAssertEqual(runResult.0, 4)
        print("runtime",runResult.1.timeIntervalDescriptionMarkedWithUnits)
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        
        let predicateSymbols = prover.symbols.keys { $0.1.type == SymbolType.Predicate }
        let expected = Set(["lives","killed","richer","hates"])
        XCTAssertEqual(Set(predicateSymbols),expected)
    }
    
    func testPUZ003() {
        let path = "PUZ001-3".p!
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = TheProver(clauses: clauses)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        let runResult = prover.run()
        XCTAssertEqual(runResult.0, 4)
        print("runtime",runResult.1.timeIntervalDescriptionMarkedWithUnits)
        XCTAssertEqual(STATUS_UNSAT, prover.status)
        
        let predicateSymbols = prover.symbols.keys { $0.1.type == SymbolType.Predicate }
        let expected = Set(["lives","killed","richer","hates"])
        XCTAssertEqual(Set(predicateSymbols),expected)
    }
    
    func _testSYO587m1() {
        let path = "SYO587-1".p!
        
        let start = CFAbsoluteTimeGetCurrent()
        
        let (result,tptpFormulae,_) = parse(path:path)
        var times = [("parsed",CFAbsoluteTimeGetCurrent()-start)]
        print(times.last!)
        
        
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(19862, tptpFormulae.count)
        times.append(("check 0",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        times.append(("mapped",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        
        
        let prover = TheProver(clauses: clauses)
        times.append(("prover",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        times.append(("check 1",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        let runResult = prover.run(1)
        XCTAssertEqual(runResult.0, 2)
        times.append(("run(1)",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        // XCTAssertEqual(STATUS_UNSAT, prover.status)
        times.append(("check 2",CFAbsoluteTimeGetCurrent()-start))
        print(times.last!)
        
        
        let predicateSymbols = prover.symbols.keys { $0.1.type == SymbolType.Predicate }
        XCTAssertEqual(predicateSymbols.count,4480)
    }
    
    
    
    
    func testPUZ056m2_030() {
        let path = "PUZ056-2.030".p!
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(41, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = TheProver(clauses: clauses)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        prover.run(1)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
    }
    
    
    /// satisfiable (no new clauses can be derived)
    func testPUZ028m3() {
        let path = "PUZ028-3".p!
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(504, tptpFormulae.count)
        
        let clauses = tptpFormulae.map { TestNode($0.root) }
        
        let prover = TheProver(clauses: clauses)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
        prover.run(10)
        
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
        XCTAssertTrue(clauses[1].isClause)
        XCTAssertTrue(clauses[2].isClause)
        XCTAssertTrue(clauses[2].nodes?.count == 3)
        
        let prover = TheProver(clauses: clauses)
        
        prover.run(5)
        
        XCTAssertEqual(STATUS_SAT, prover.status)
        
    }
    
}
