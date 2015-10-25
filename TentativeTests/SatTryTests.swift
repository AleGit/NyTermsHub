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
    var utau : type_t = 0
    var btau : type_t = 0
    var gtrm : term_t = 0

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        yices_init()    // global initialization
        
        // utau = yices_new_uninterpreted_type()
        utau = yices_int_type()
        btau = yices_bool_type()
        
        gtrm = yices_new_uninterpreted_term(utau)
        yices_set_term_name(gtrm, "⊥")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        yices_exit()
        super.tearDown()
    }
    
    func testPropositions() {
        let ctx = yices_new_context(nil)
        defer {  yices_free_context(ctx) }
        
        let p = yices_new_uninterpreted_term(btau)
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
        defer {
            yices_free_context(ctx) }
        
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
    
    func build_yices_term<N:Node>(term:N, tau:type_t) -> term_t {
        
        guard let terms = term.terms else { return gtrm }   // map variables to constant '⊥'
        
        switch term.symbol {
        case "~":
            assert(terms.count == 1)
            
            return yices_not( build_yices_term(terms[0], tau:btau))
            
        case "|":
            var args = terms.map { build_yices_term($0, tau: btau) }
            return yices_or( UInt32(terms.count), &args)
            
        
        default:
            
            var t = yices_get_term_by_name(term.symbol)     // constant c, function f
            
            if t == NULL_TERM {
                if terms.count == 0 {
                    // proposition or (function) constant
                    t = yices_new_uninterpreted_term(tau)
                    yices_set_term_name(t, term.symbol)
                }
                else {
                    let ftype = yices_function_type(UInt32(terms.count), [type_t](count:terms.count, repeatedValue:utau), tau)
                    t = yices_new_uninterpreted_term(ftype)
                    yices_set_term_name(t, term.symbol)
                }
            }
            
            if terms.count > 0 {
                let yterms = terms.map { build_yices_term($0, tau:utau) }
                t = yices_application(t, UInt32(yterms.count), yterms)
            }
            
            return t
        }
        
    }
    
    func testPUZ00m1() {
        
        // parse
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p"
        
        let (result,annotatedFormulae,_) = parsePath(path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(12, annotatedFormulae.count)
        
        
        // check
        let ctx = yices_new_context(nil)
        defer {
            print("yices_free_context")
            yices_free_context(ctx) }
        
        var clauses = [term_t]()
        
        for aFormula in annotatedFormulae {
            let clause = build_yices_term(aFormula.formula, tau:btau)
            
            print(aFormula.formula)
            print(String(term:clause)!)
            yices_assert_formula(ctx, clause)
            let status = yices_check_context(ctx, nil)
            XCTAssertTrue(STATUS_SAT == status)
            
            XCTAssertEqual(0, yices_term_is_atomic(clause))
            XCTAssertEqual(1, yices_term_is_composite(clause))
            XCTAssertEqual(1, yices_term_is_bool(clause))
            XCTAssertEqual(0, yices_term_is_sum(clause))
            XCTAssertEqual(0, yices_term_is_bvsum(clause))
            XCTAssertEqual(0, yices_term_is_product(clause))
            
            
            let tcount = aFormula.formula.terms!.count
            let ccount = Int(yices_term_num_children(clause))
            
            switch tcount {
            case 0:
                XCTFail()
            case 1:
                
                    
                print(ccount)
            
            default:
                XCTAssertEqual(tcount, ccount)
                
                
                
                clauses.append(clause)
            }
            print("")
            
            
        }
        
        let mdl = yices_get_model(ctx, 1);
        defer {
            print("yices_free_model")
            yices_free_model(mdl)
        }
        
        XCTAssertNotNil(mdl)
        print(String(model:mdl)!)
        print("")
        
        for clause in clauses {
            let ccount = yices_term_num_children(clause)
            for idx in 0..<ccount {
                let child = yices_term_child(clause, Int32(idx))
                
                print(String(term:child), yices_formula_true_in_model(mdl, child))
                
            }
            print(String(term:clause), yices_formula_true_in_model(mdl, clause))
            print("")
        }
        
        
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
