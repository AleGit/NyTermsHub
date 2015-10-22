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
        
        yices_init()    // global initialization
        defer {
            yices_exit()    // global cleanup
        }
        
        let ctx = yices_new_context(nil) // nil == NULL == default configuration
        defer {
            yices_free_context(ctx)
        }
        
        // let tau = yices_new_uninterpreted_type()
        let tau = yices_int_type()
        let truth = yices_bool_type()
        
        let unary = yices_function_type1(tau, tau)
        let predicate = yices_function_type1(tau, truth)
        
        let c = yices_new_uninterpreted_term(tau)   // 'constant' with unknown value of unknown type
        yices_set_term_name(c, "c")
        let p = yices_new_uninterpreted_term(predicate)
        yices_set_term_name(p, "p")
        let f = yices_new_uninterpreted_term(unary)
        yices_set_term_name(f, "f")
        let fc = yices_application1(f, c)
        let pfc = yices_application1(p, fc)
        let npfc = yices_not(pfc)
    
        let wahr = yices_or2(pfc,npfc)
        let falsch = yices_and2(pfc, npfc)
        
        print(String(term:pfc)!)
        print(String(term:npfc)!)
        
        yices_assert_formula(ctx, npfc)
        XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
        
        
        let mdl = yices_get_model(ctx, 1);
        defer {
            yices_free_model(mdl)
        }
        
        print(String(model:mdl)!)
        
//        let i: Int = 0
//        
        let pfc_val = yices_get_bool_value(mdl, pfc, pvalue)
        
        print("pfc:\(pfc_val)")
        
        let npfc_val = yices_get_bool_value(mdl, npfc, pvalue)
        
        print("pfc:\(npfc_val)")
        
        let pfc_in_model = yices_formula_true_in_model(mdl,pfc)
        let npfc_in_model = yices_formula_true_in_model(mdl,npfc)
        
        print("pfc in model:\(pfc_in_model)")
        print("npfc in model:\(npfc_in_model)")

      
        yices_assert_formula(ctx, pfc)
        XCTAssertTrue(STATUS_UNSAT == yices_check_context(ctx, nil))
        
        yices_reset_context(ctx)
        yices_assert_formula(ctx, wahr)
        XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
        
        yices_reset_context(ctx)
        yices_assert_formula(ctx, falsch)
        XCTAssertTrue(STATUS_UNSAT == yices_check_context(ctx, nil))
        
        yices_reset_context(ctx)
        yices_assert_formula(ctx, yices_implies(falsch, wahr))
        XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
        
        
        
        
        
        
        
        
        
        
        
    }
}
