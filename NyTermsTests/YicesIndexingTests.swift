//
//  YicesIndexingTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 12.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class YicesIndexingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        yices_init()
    }
    
    override func tearDown() {
        yices_exit()
        super.tearDown()
    }
    
    let a = "f(g(X,Y))"
    let b = "g(h(Z),X)"
    
    

    func testLiterals() {
        let p = "p(\(a),\(b))"
        let np = "~\(p)"
        let e = "\(a)=\(b)"
        let ne = "~\(e)"
        
        let literals = [
            TptpNode(stringLiteral:p),
            TptpNode(stringLiteral:e),
            TptpNode(stringLiteral:ne).negated!.negated!,
            TptpNode(stringLiteral:np)]
        
        let ls = literals.map { ($0, Yices.literal($0)) }
        let nls = ls.map { ($0.0.negated!, Yices.not($0.1)) }
        
        print(ls)
        print(nls)
        
        XCTAssertEqual(ls[0].1, nls[3].1)
        XCTAssertEqual(ls[1].1, nls[2].1)
        XCTAssertEqual(ls[2].1, nls[1].1)
        XCTAssertEqual(ls[3].1, nls[0].1)
        
        XCTAssertEqual(ls[0].1, Yices.literal(nls[3].0))
        XCTAssertEqual(ls[1].1, Yices.literal(nls[2].0))
        XCTAssertEqual(ls[2].1, Yices.literal(nls[1].0))
        XCTAssertEqual(ls[3].1, Yices.literal(nls[0].0))
        
        XCTAssertEqual(ls[0].0, nls[3].0)
        XCTAssertEqual(ls[1].0, nls[2].0)
        XCTAssertEqual(ls[2].0, nls[1].0)
        XCTAssertEqual(ls[3].0, nls[0].0)
    }
    
    func testSimpleClauses() {
        let clauses = ["p|~p" as TptpNode, "~p|p", "p|p|p|~p" ]
        let y = clauses.map {
            
            ($0, Yices.clause($0).1, Yices.clause($0).2) }
        print(y)
    }
    
    
    
    func testClauses() {
        let p = "p(\(a),\(b))"
        let np = "~\(p)"
        let e = "\(a)=\(b)"
        let ne = "~\(e)"
        
        let clauses = [
            TptpNode(stringLiteral: "\(p)|\(ne)"),
            TptpNode(stringLiteral: "\(ne)|\(p)|\(ne)"),
            TptpNode(stringLiteral: "\(ne)|\(p)|\(p)|\(ne)")
        ]
        let y = clauses.map {
            
            ($0, Yices.clause($0).1, Yices.clause($0).2) }
        print(y)
    }
    
    func testSampleClauses() {
        let xy = TptpNode(equational:"=", nodes:["X","Y"])
        let clauses : [TptpNode] = [
            "p(X,Y)  | p(X,Y)  | X = Y",
            "~p(X,Y) | ~p(X,Y) | X = Y",    
            "p(X,Y)  | p(X,Y)  | X != Y",   
            "~p(X,Y) | ~p(X,Y) | X != Y",   
            "X = Y   | Y != Z  | p(X,Y)",
            "p(X,Y)  | ~p(X,Y) | X != Y",
            "p(X,Y)  | ~p(X,Y) | X = Y",
            TptpNode(connective:"|", nodes:["p(X,Y)"]),
            TptpNode(connective:"|", nodes:["~p(X,Y)"]),
            TptpNode(connective:"|", nodes:["X != Y"]),
            TptpNode(connective:"|", nodes:[xy]),
            
        ]
        
        /*
         "p(⊥,⊥)  | p(⊥,⊥)  | ⊥ = ⊥",       (2, [2, 10, 10], [10, 10, 2])
         "~p(⊥,⊥) | ~p(⊥,⊥) | ⊥ = ⊥",       (2, [2, 11, 11], [11, 11, 2])
         "p(⊥,⊥)  | p(⊥,⊥)  | ⊥ != ⊥",      (10, [10, 10, 10], [10, 10, 3])
         "~p(⊥,⊥) | ~p(⊥,⊥) | ⊥ != ⊥",      (11, [11, 11, 11], [11, 11, 3])
         "⊥ = ⊥   | ⊥ != ⊥"                 (2, [2, 3], [2, 3])
         "⊥ = ⊥   | ⊥ != ⊥  | p(⊥,⊥)",      (2, [2, 3, 10], [2, 3, 10])
         "p(⊥,⊥)  | ~p(⊥,⊥) | ⊥ != ⊥",      (2, [10, 10, 11], [10, 11, 3])
         "p(⊥,⊥)  | ~p(⊥,⊥) | ⊥ = ⊥",       2, [2, 10, 11], [10, 11, 2])
         */
 
        let yicesTriples = clauses.map {
            Yices.clause($0)
        }
        
        print(yicesTriples.map { "\($0)" }.joinWithSeparator("\n"))
        
        for t:term_t in 0...11 {
        print(t, String(term:t))
        }
    }

}
