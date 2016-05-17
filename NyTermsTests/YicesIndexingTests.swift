//
//  YicesIndexingTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 12.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

private let fgxy = "f(g(X,Y))"
private let ghzx = "g(h(Z),X)"

private let p = "p(\(fgxy),\(ghzx))"
private let np = "~\(p)"
private let e = "\(fgxy)=\(ghzx)"
private let ne = "\(fgxy)!=\(ghzx)"


class YicesIndexingTests: YicesTestCase {
    

    
    func testLiterals() {
        let literals = [
            TptpNode(stringLiteral:p),
            TptpNode(stringLiteral:e),
            TptpNode(stringLiteral:ne),
            TptpNode(stringLiteral:np)
        ]
        
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
        let clauses = [
            TptpNode(stringLiteral: "\(p)|\(ne)"),
            TptpNode(stringLiteral: "\(ne)|\(p)|\(ne)"),
            TptpNode(stringLiteral: "\(ne)|\(p)|\(p)|\(ne)")
        ]
        let y = clauses.map {
            
            ($0, Yices.clause($0).1, Yices.clause($0).2) }
        print(y)
    }
    
    func testTrue() {
        let clauses : [TptpNode] = [
            TptpNode(connective:"|", nodes: ["X = Y"]),
            "p | X = Y",
            "~p | X = Y",
            "X != Y | p | ~p",
            "q(X) | p | ~p",
            "q(f(X)) | p | ~p",
        ]
        
        for clause in clauses {
            let triple = Yices.clause(clause)
            XCTAssertEqual(triple.0, Yices.top, String(term:triple.0) ?? "")
            print(triple)
        }
    }
    
    func testSampleClauses() {
        let x_equals_y = TptpNode(equational:TptpNode.symbol(.Equation), nodes:["X","Y"])
        let x_neq_y = TptpNode(equational:TptpNode.symbol(.Inequation), nodes:["X","Y"])
        let clauses : [TptpNode] = [
            "p(X,Y)  | ~p(X,Y)",
            "X = Y | X != Y",
            "p(X,Y)  | p(X,Y)  | X = Y",
            "~p(X,Y) | ~p(X,Y) | X = Y",
            "p(X,Y)  | p(X,Y)  | X != Y",
            "~p(X,Y) | ~p(X,Y) | X != Y",
            "X = Y   | Y != Z  | p(X,Y)",
            "p(X,Y)  | ~p(X,Y) | X != Y",
            "p(X,Y)  | ~p(X,Y) | X = Y",
            TptpNode(connective:"|", nodes:["p(X,Y)"]),
            TptpNode(connective:"|", nodes:["~p(X,Y)"]),
            TptpNode(connective:"|", nodes:[x_neq_y]),
            TptpNode(connective:"|", nodes:[x_equals_y]),
            TptpNode(connective:"|", nodes:[x_neq_y,x_equals_y]),
            ]
        
        let yicesTriples = clauses.map {
            Yices.clause($0)
        }
        
        for triple in yicesTriples {
            print("\(triple.2) ≡ \(triple.1) ≡ \(triple.0) \(Yices.children(triple.0))")
        }
        
        print("")
        
        for t:term_t in 0..<200 {
            guard let s = String(term:t) else {
                continue
            }
            print(t, s)
        }
    }
    
}
