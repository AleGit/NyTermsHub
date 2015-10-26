//
//  SatTryTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 20.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
import NyTerms

class YicesSatTrials : XCTestCase {
    private var free_tau : type_t = 0
    private var bool_tau : type_t = 0
    private var general_constant : term_t = 0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        yices_init()    // global initialization
        
        // uni_type = yices_new_uninterpreted_type()
        free_tau = yices_int_type()
        bool_tau = yices_bool_type()
        
        general_constant = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(general_constant, "⊥")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        yices_exit()
        super.tearDown()
    }
    
    func testPropositions() {
        let ctx = yices_new_context(nil)
        defer {  yices_free_context(ctx) }
        
        let p = yices_new_uninterpreted_term(bool_tau)
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
        defer { yices_free_context(ctx) }
        
        // types
        let unary = yices_function_type1(free_tau, free_tau)    // (tau) -> tau
        
        let c = yices_new_uninterpreted_term(free_tau)
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
        
        let unary = yices_function_type1(free_tau, free_tau)        // (tau) -> tau
        let predicate = yices_function_type1(free_tau, bool_tau)    // (tau) -> bool
        
        let c = yices_new_uninterpreted_term(free_tau)
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
    
    func build_yices_term<N:Node>(term:N, range_tau:type_t) -> term_t {
        
        guard let terms = term.terms else { return general_constant }   // map variables to constant '⊥'
        
        switch term.symbol {
        case "~":
            assert(terms.count == 1)
            return yices_not( build_yices_term(terms.first!, range_tau:bool_tau))
            
        case "|":
            var args = terms.map { build_yices_term($0, range_tau: bool_tau) }
            return yices_or( UInt32(terms.count), &args)
            
        case "&":
            var args = terms.map { build_yices_term($0, range_tau: bool_tau) }
            return yices_and( UInt32(terms.count), &args)
            
        default:
            
            var t = yices_get_term_by_name(term.symbol)     // constant c, function f
            
            if t == NULL_TERM {
                if terms.count == 0 {
                    // proposition or (function) constant
                    t = yices_new_uninterpreted_term(range_tau)
                    yices_set_term_name(t, term.symbol)
                }
                else {
                    let domain_taus = [type_t](count:terms.count, repeatedValue:free_tau)
                    let func_tau = yices_function_type(UInt32(terms.count), domain_taus, range_tau) // (tau,...,tau) -> range_tau
                    t = yices_new_uninterpreted_term(func_tau)
                    yices_set_term_name(t, term.symbol)
                }
            }
            
            if terms.count > 0 {
                let args = terms.map { build_yices_term($0, range_tau:free_tau) }
                t = yices_application(t, UInt32(args.count), args)
            }
            
            return t
        }
        
    }
    
    func testEmptyJunctions() {
        let emptyDisjunction = NodeStruct(connective:"|", terms:[NodeStruct]())
        let emtpyConjunction = NodeStruct(connective:"&", terms:[NodeStruct]())
        XCTAssertEqual(0, emptyDisjunction.terms?.count)
        XCTAssertEqual(0, emtpyConjunction.terms?.count)
        
        // no context needed
        
        let F = build_yices_term(emptyDisjunction, range_tau: bool_tau)
        let T = build_yices_term(emtpyConjunction, range_tau: bool_tau)
        
        XCTAssertEqual("false",String(term:F))      // an empty disjunction is unsatisfiable
        XCTAssertEqual("true",String(term:T))       // an empty conjunction is valid
    }
    
    func testPUZ001m1_step1() {
        
        // parse
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p"
        
        let (result,tptpFormulae,_) = parsePath(path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        // check
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        var tptpClauses = tptpFormulae.map { $0.formula }
        
        let clauses = tptpClauses.map {
            (tptpClause) -> (TptpNode,term_t) in
            let clause = build_yices_term(tptpClause, range_tau:bool_tau)
            
            XCTAssertEqual(0, yices_term_is_atomic(clause))
            XCTAssertEqual(1, yices_term_is_composite(clause))
            XCTAssertEqual(1, yices_term_is_bool(clause))
            XCTAssertEqual(0, yices_term_is_sum(clause))
            XCTAssertEqual(0, yices_term_is_bvsum(clause))
            XCTAssertEqual(0, yices_term_is_product(clause))
            
            yices_assert_formula(ctx, clause)
            XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
            
            let tcount = tptpClause.terms!.count
            let ccount = Int(yices_term_num_children(clause))
            
            if tcount > 1 {
                XCTAssertEqual(tcount, ccount)
            }
            
            return (tptpClause,clause)
        }
        
        let mdl = yices_get_model(ctx, 1);
        defer { yices_free_model(mdl) }
        
        XCTAssertNotNil(mdl)
        
        let selected = clauses.map {
            (tptpClause,clause) -> TptpNode in
            
            guard let terms = tptpClause.terms else { return TptpNode(connective:"|",terms:[TptpNode]()) } // false
            
            switch terms.count {
            case 0:
                return TptpNode(connective:"|",terms:[TptpNode]())  // false
            case 1:
                XCTAssertEqual(1, yices_formula_true_in_model(mdl, clause))
                return tptpClause
            case let tcount:
                let ccount = Int(yices_term_num_children(clause))
                XCTAssertEqual(tcount, ccount)
                
                for idx in 0..<ccount {
                    let child = yices_term_child(clause, Int32(idx))
                    XCTAssertEqual(1, yices_term_is_bool(child))
                    if yices_formula_true_in_model(mdl, child) == 1 {
                        return terms[idx]
                    }
                }
            }
            
            return TptpNode(connective:"|",terms:[TptpNode]())  // false
        }
        
        var newClauses = [TptpNode]()
        
        for i in 0..<(selected.count-1) {
            for j in (i+1)..<selected.count {
                let a = selected[i]
                let b = selected[j]
                
                var unifier : [TptpNode : TptpNode]? = nil
                
                switch (a.symbol, b.symbol) {
                case ("~","~"):
                    unifier = nil
                case ("~",_):
                    
                    unifier = a.terms!.first! =?= b
                case (_,"~"):
                    
                    unifier = a =?= b.terms!.first!
                default:
                    unifier = nil
                }
                
                if unifier != nil {
                    
                    let na = tptpClauses[i] * unifier!
                    let nb = tptpClauses[j] * unifier!
                    
                    print(na,nb)
                    
                    newClauses.append(na)
                    newClauses.append(nb)
                }
            }
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
