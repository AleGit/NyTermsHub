//
//  YicesTestCase.swift
//  NyTerms
//
//  Created by Alexander Maringele on 17.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//


import XCTest
@testable import NyTerms


class YicesTestCase : XCTestCase {
    override func setUp() {
        super.setUp()
        yices_init()
        resetGlobalStringSymbols()
    }
    
    override func tearDown() {
        yices_exit()
        super.tearDown()
    }
    
    func testNegations() {
        
        let p = "p(f(X,Y))" as TptpNode
        let np = "~p(f(A,B))" as TptpNode
        
        XCTAssertEqual(p.description, "p(f(X,Y))")
        XCTAssertEqual(np.description, "~(p(f(A,B)))")
        
        let yp = Yices.clause(p).yicesClause    // p
        let ynp = Yices.clause(np).yicesClause   // ~p
        
        let ypt = yices_type_of_term(yp)
        let ynpt = yices_type_of_term(ynp)
        
        print(yp,  ypt, String(tau:ypt)!)
        print(ynp, ynpt, String(tau:ynpt)!)
        
        let nyp = yices_not(yp) // ~p
        let nynp = yices_not(ynp) // ~~p
        
        XCTAssertEqual(yp, nynp)    // p = ~~p
        XCTAssertEqual(ynp, nyp)    // ~p = ~p
        XCTAssertEqual(yices_not(nynp), nyp)
        
        
    }
    
}