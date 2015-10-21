//
//  SatTryTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 20.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
import NyTerms

class SatTryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPropositions() {
        yices_init()    // global initialization
        defer {
            yices_exit()    // global cleanup
        }
        
        let ctx = yices_new_context(nil) // nil == NULL == default configuration
        defer {
            yices_free_context(ctx)
        }
        
        let tau = yices_bool_type()
        
        let p = yices_new_uninterpreted_term(tau)
        let np = yices_not(p)
        let wahr = yices_or2(p, np)
        let falsch = yices_and2(p, np)
        let nichtwahr = yices_not(wahr)
        
        yices_assert_formula(ctx, p)
        XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
        yices_assert_formula(ctx, np)
        XCTAssertTrue(STATUS_UNSAT == yices_check_context(ctx, nil))

        
        
        yices_reset_context(ctx)
        yices_assert_formula(ctx, wahr)
        XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
        
        yices_reset_context(ctx)
        yices_assert_formula(ctx, falsch)
        XCTAssertTrue(STATUS_UNSAT == yices_check_context(ctx, nil))
        
        yices_reset_context(ctx)
        yices_assert_formula(ctx, nichtwahr)
        XCTAssertTrue(STATUS_UNSAT == yices_check_context(ctx, nil))
    }
    
    func testPredicates() {
        
    }
}
