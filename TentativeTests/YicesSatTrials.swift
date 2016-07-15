//
//  SatTryTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 20.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
@testable
import NyTerms

class YicesSatTrials : YicesTestCase {
    private var free_tau : type_t = NULL_TYPE           // i.e. not a type
    private var bool_tau : type_t = NULL_TYPE           // i.e. not a type
    private var general_constant : term_t = NULL_TERM   // i.e. not a term
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // uni_type = yices_new_uninterpreted_type()
        free_tau = Yices.int_tau
        bool_tau = Yices.bool_tau
        
        general_constant = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(general_constant, "∴")
    }
    
    /// test creates
    /// - atom 'p'
    /// - composites 'p', 'p p', 'p 'p', and 
    
    func testTryPropositions() {
        let ctx = yices_new_context(nil)
        defer {  yices_free_context(ctx) }
        
        let p = Yices.typedSymbol("p", term_tau: Yices.bool_tau)
        let np = yices_not(p)
        let wahr = yices_or2(p, np)
        let falsch = yices_and2(p, np)
        let nichtwahr = yices_not(wahr)
        
        yices_assert_formula(ctx, p)
        XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
        
        let mdl = yices_get_model(ctx, 1);
        defer { yices_free_model(mdl) }
        
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
    
    func testTryEquations() {
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        let domain = Yices.domain(1, tau:Yices.free_tau)
        let range = Yices.free_tau
        
        let c = Yices.constant("c", term_tau: range)
        let f = Yices.function("f", domain: domain, range: range)    // (tau) -> tau
        let g = Yices.function("g", domain: domain, range: range)    // (tau) -> tau
        
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
    
    func testTryPredicates() {
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
    
    func build_yices_term<N:Node where N.NyTerms.Symbol==String>(_ term:N, range_tau:type_t) -> term_t {
        
        guard let nodes = term.nodes else { return general_constant }   // map variables to constant '⊥'
        
        switch term.symbol {
        case "~":
            assert(nodes.count == 1)
            return yices_not( build_yices_term(nodes.first!, range_tau:bool_tau))
            
        case "|":
            var args = nodes.map { build_yices_term($0, range_tau: bool_tau) }
            return yices_or( UInt32(nodes.count), &args)
            
        case "&":
            var args = nodes.map { build_yices_term($0, range_tau: bool_tau) }
            return yices_and( UInt32(nodes.count), &args)
            
        case "!=":
            assert(nodes.count == 2)
            let args = nodes.map { build_yices_term($0, range_tau: free_tau) }
            return yices_neq(args.first!,args.last!)
            
        case "=":
            assert(nodes.count == 2)
            let args = nodes.map { build_yices_term($0, range_tau: free_tau) }
            return yices_eq(args.first!,args.last!)
            
        default:
            
            var t = yices_get_term_by_name(term.symbol)     // constant c, function f
            
            if t == NULL_TERM {
                if nodes.count == 0 {
                    // proposition or (function) constant
                    t = yices_new_uninterpreted_term(range_tau)
                    yices_set_term_name(t, term.symbol)
                }
                else {
                    let domain_taus = [type_t](repeating: free_tau, count: nodes.count)
                    let func_tau = yices_function_type(UInt32(nodes.count), domain_taus, range_tau) // (tau,...,tau) -> range_tau
                    t = yices_new_uninterpreted_term(func_tau)
                    yices_set_term_name(t, term.symbol)
                }
            }
            
            if nodes.count > 0 {
                let args = nodes.map { build_yices_term($0, range_tau:free_tau) }
                t = yices_application(t, UInt32(args.count), args)
            }
            
            return t
        }
        
    }
    
    func testTryEmptyJunctions() {
        let emptyDisjunction = NodeStruct(symbol:"|", nodes:[NodeStruct]())
        let emtpyConjunction = NodeStruct(symbol:"&", nodes:[NodeStruct]())
        XCTAssertEqual(0, emptyDisjunction.nodes?.count)
        XCTAssertEqual(0, emtpyConjunction.nodes?.count)
        
        // no context needed
        
        let F = build_yices_term(emptyDisjunction, range_tau: bool_tau)
        let T = build_yices_term(emtpyConjunction, range_tau: bool_tau)
        
        XCTAssertEqual("false",String(term:F))      // an empty disjunction is unsatisfiable
        XCTAssertEqual("true",String(term:T))       // an empty conjunction is valid
    }
    
    func testTryPUZ001cnf1() {
        
        // parse
        let path = "PUZ001-1".p!
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        // check
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        var tptpClauses = tptpFormulae.map { $0.root }
        
        let yicesClauses = tptpClauses.map {
            (tptpClause) -> (TptpNode,clause:term_t,after:Set<term_t>,before:[term_t]) in
            let triple = Yices.clause(tptpClause)
            
            XCTAssertEqual(0, yices_term_is_atomic(triple.0), "\n\(tptpClause) \(triple)")
            XCTAssertEqual(1, yices_term_is_composite(triple.0), "\n\(tptpClause) \(triple)")
            XCTAssertEqual(1, yices_term_is_bool(triple.0), "\n\(tptpClause) \(triple)")
            XCTAssertEqual(0, yices_term_is_sum(triple.0), "\n\(tptpClause) \(triple)")
            XCTAssertEqual(0, yices_term_is_bvsum(triple.0), "\n\(tptpClause) \(triple)")
            XCTAssertEqual(0, yices_term_is_product(triple.0), "\n\(tptpClause) \(triple)")
            
            yices_assert_formula(ctx, triple.0)
            XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
            
            let tcount = tptpClause.nodes!.count
            let ccount = Int(yices_term_num_children(triple.0))
            
            if tcount > 1 {
                XCTAssertEqual(tcount, ccount)
            }
            
            return (tptpClause,triple.0, triple.1, triple.2)
        }
        
        let mdl = yices_get_model(ctx, 1);
        defer { yices_free_model(mdl) }
        
        XCTAssertNotNil(mdl)
        
        
    }
    
    func testTrySymbols() {
        let ctx = yices_new_context(nil)
        defer {  yices_free_context(ctx) }
        
        let a = yices_new_uninterpreted_term(free_tau)   // 'constant' with unknown value of free type
        yices_set_term_name(a, "1")
        
        let b = yices_new_uninterpreted_term(free_tau)   // 'constant' with unknown value of free type
        yices_set_term_name(b, "⊥")
        
        let c = yices_new_uninterpreted_term(free_tau)   // 'constant' with unknown value of free type
        yices_set_term_name(c, "'Hällo, Wörld!'")
        //  ⊕ ⊖ ⊗ ⊘
        
        let binary = yices_function_type(2, [free_tau,free_tau], free_tau)
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
