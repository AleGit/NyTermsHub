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
        Nylog.reset(loglevel:.Error)
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
        
        Nylog.printparts()
        
        XCTAssertEqual(status, STATUS_UNSAT)
        
    }
    
    /// Since yices handles EUF correctly f(X)!=f(Y) is immediatyl proven inconsistent.
    func testFxNeqFy() {
        let clauses = [
            TptpNode(connective:"|", nodes:["f(X)!=f(Y)"]),
        ]
        
        let prover = MingyProver(clauses: clauses)
        
        let (status,_,_) = prover.run(1.0)
        
        Nylog.printparts()
        
        XCTAssertEqual(status, STATUS_UNSAT)
        
    }
    
    func testFaNeqFb() {
        let clauses = [
            TptpNode(connective:"|", nodes:["f(a)!=f(b)"]),
            TptpNode(connective:"|", nodes:["X=Y"])
            ]
        
        let prover = MingyProver(clauses: clauses)
        
        let (status,_,_) = prover.run(1.0)
        
        Nylog.printparts()
        
        XCTAssertEqual(status, STATUS_UNSAT)
        
    }
    
    func testAxioms() {
        let clauses = [
            // TptpNode(connective:"|", nodes:["p(a)"]),
            TptpNode(connective:"|", nodes:["~p(f(a,e))"]),
            // TptpNode(connective:"|", nodes:["f(X,e)=X"]),
            
            // TptpNode(connective:"|", nodes:["X=X"]),    // reflexivity
            // "X!=Y | Y=X",                                 // symmetry
            // "X!=Y | X!=Z | X=Y",                            // transitivity
            
            // "X1!=Y1 | X2!=Y2 | f(X1,X2)=f(Y1,Y2)",          // function congruence
            "X!=Y|~p(X)|p(Y)"                            // predicate congruence
            
            ]
        
        let prover = MingyProver(clauses: clauses)
        
        let (status,_,_) = prover.run(10.0)
        
        Nylog.printparts()
        
        XCTAssertEqual(status, STATUS_UNSAT)
    }
    
    func testIndex() {
        var trie = TrieClass<SymHop<String>,Int>()
        
//        let l0 = "q(X)" as TptpNode
//        for path in l0.paths {
//            trie.insert(path, value: 13)
//        }
        
        
        
        let l1 = "p(X)" as TptpNode
        for path in l1.paths {
            print("l1",l1,path)
            trie.insert(path, value: 23)
        }
        
        let l2 = "~p(f(a,e))" as TptpNode
        for path in l2.paths {
            print("l2",l2,path)
            trie.insert(path, value: 33)
        }
        
        XCTAssertNotNil(l1 ~?= l2)
        
        print("trie: *****")
        print(trie)
        print("************")
        
        let cc1 = candidateComplementaries(trie, term: l1)
        // let cc2 = candidateComplementaries(trie, term: l2)
        
        XCTAssertEqual(Set(arrayLiteral:33), cc1)
        // XCTAssertEqual(Set(arrayLiteral:23), cc2)
        Nylog.printparts()
        
        
    }
    
    

}
