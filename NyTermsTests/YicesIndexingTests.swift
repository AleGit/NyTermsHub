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

}
