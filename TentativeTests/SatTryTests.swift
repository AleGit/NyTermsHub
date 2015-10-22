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
        yices_init()    // global initialization
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        yices_exit()
        super.tearDown()
    }
    
    func testPropositions() {
        let ctx = yices_new_context(nil)
        defer {  yices_free_context(ctx) }
        
        let tau = yices_bool_type()
        
        let p = yices_new_uninterpreted_term(tau)
        let np = yices_not(p)
        let wahr = yices_or2(p, np)
        let falsch = yices_and2(p, np)
        let nichtwahr = yices_not(wahr)
        
        yices_assert_formula(ctx, p)
        XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
        
        let mdl = yices_get_model(ctx, 1);
        defer {
            yices_free_model(mdl)
        }
        
        var bvalue : Int32 = -1
        
        for (formula,expected):(term_t,Int32) in [(p,1),(np,0), (wahr,1), (falsch,0), (nichtwahr,0)
            ] {
            let name = String(term:formula)
            let code = yices_get_bool_value(mdl, formula, &bvalue)
            XCTAssertEqual(0,code,name!)
            XCTAssertEqual(expected,bvalue,name!)
            let mval = yices_formula_true_in_model(mdl, formula)
            
             print("\(name) : \(bvalue) \(mval)")
                
        }
        
        yices_assert_formula(ctx, np)
        XCTAssertTrue(STATUS_UNSAT == yices_check_context(ctx, nil))
    }
    
    func testEquations() {
        let ctx = yices_new_context(nil)
        defer {  yices_free_context(ctx) }
        
        // types
        let tau = yices_new_uninterpreted_type()
        let truth = yices_bool_type()
        let unary = yices_function_type1(tau, tau)
        
        let c = yices_new_uninterpreted_term(tau)   // 'constant' with unknown value of unknown type
        yices_set_term_name(c, "c")
        let f = yices_new_uninterpreted_term(unary)
        yices_set_term_name(f, "f")
        let g = yices_new_uninterpreted_term(unary)
        yices_set_term_name(g, "g")
        
        let fc = yices_application1(f, c)
        let gc = yices_application1(g, c)
        
        let eq = yices_eq(fc, gc)
        let ne = yices_neq(fc, gc)
        let neq = yices_not(eq)
        
        yices_assert_formula(ctx, ne)
        XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))

        let mdl = yices_get_model(ctx, 1);
        defer {
            yices_free_model(mdl)
        }
        
        print(String(model:mdl)!)
        
        var bvalue : Int32 = -1
        
        for (formula,expected):(term_t,Int32) in [(eq,0), (ne,1), (neq,1)] {
            let name = String(term:formula)
            let code = yices_get_bool_value(mdl, formula, &bvalue)
            XCTAssertEqual(0,code,name!)
            XCTAssertEqual(expected,bvalue,name!)
            let mval = yices_formula_true_in_model(mdl, formula)
            
            print("\(name) : \(bvalue) \(mval)")
        }
        
        yices_assert_formula(ctx, eq)
        XCTAssertTrue(STATUS_UNSAT == yices_check_context(ctx, nil))
    }
    
    func testPredicates() {
        let ctx = yices_new_context(nil)
        defer {  yices_free_context(ctx) }
        
        let tau = yices_new_uninterpreted_type()
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
        
        var bvalue : Int32 = -1
        
        for (formula,expected):(term_t,Int32) in [(pfc,0), (npfc,1), (wahr,1), (falsch,0)] {
            let name = String(term:formula)
            let code = yices_get_bool_value(mdl, formula, &bvalue)
            XCTAssertEqual(0,code,name!)
            XCTAssertEqual(expected,bvalue,name!)
            let mval = yices_formula_true_in_model(mdl, formula)
            
            print("\(name) : \(bvalue) \(mval)")
        }
      
        yices_assert_formula(ctx, pfc)
        XCTAssertTrue(STATUS_UNSAT == yices_check_context(ctx, nil))
    }
    
    func testSymbols() {
        let ctx = yices_new_context(nil)
        defer {  yices_free_context(ctx) }
        
        let tau = yices_new_uninterpreted_type()
        
        let a = yices_new_uninterpreted_term(tau)   // 'constant' with unknown value of unknown type
        yices_set_term_name(a, "1")
        
        let b = yices_new_uninterpreted_term(tau)   // 'constant' with unknown value of unknown type
        yices_set_term_name(b, "⊥")
        
        let c = yices_new_uninterpreted_term(tau)   // 'constant' with unknown value of unknown type
        yices_set_term_name(c, "'Hällo, Wörld!'")
        //  ⊕ ⊖ ⊗ ⊘
        
        let binary = yices_function_type(2, [tau,tau], tau)
        let xor = yices_new_uninterpreted_term(binary)
        yices_set_term_name(xor, "⊕")
        
        let axorb = yices_application2(xor, a, b)
        let bxorc = yices_application2(xor, b, c)
        
        var s = String(term:b)
        print(s)
        XCTAssertEqual("⊥", s)
        
        s = String(term:axorb)
        print(s)
        XCTAssertEqual("(⊕ 1 ⊥)", s)
        
        s = String(term:bxorc)
        print(s)
        XCTAssertEqual("(⊕ ⊥ 'Hällo, Wörld!')", s)
        
    }
}
