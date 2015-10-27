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
    
    func testTryPropositions() {
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
    
    func testTryEquations() {
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
            
        case "!=":
            assert(terms.count == 2)
            let args = terms.map { build_yices_term($0, range_tau: free_tau) }
            return yices_neq(args.first!,args.last!)
            
        case "=":
            assert(terms.count == 2)
            let args = terms.map { build_yices_term($0, range_tau: free_tau) }
            return yices_eq(args.first!,args.last!)
            
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
    
    func testTryEmptyJunctions() {
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
    
    func testTryPUZ001cnf1() {
        
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
                
                if let unifier = a ~?= b {
                    
                    let na = tptpClauses[i] * unifier
                    let nb = tptpClauses[j] * unifier
                    
                    print(na,nb)
                    
                    newClauses.append(na)
                    newClauses.append(nb)
                }
            }
        }
    }
    
  
// Mac mini Server (Late 2012)
//    Test Suite 'Selected tests' started at 2015-10-27 08:44:34.855
//    Test Suite 'YicesSatTrials' started at 2015-10-27 08:44:34.855
//    Test Case '-[NyTermsTests.YicesSatTrials testTryHWV134cnf1]' started.
//    (2015-10-27 07:44:34 +0000, "parsePath()", "start")
//    (2015-10-27 07:45:19 +0000, "parsePath()", "finish")
//    (2015-10-27 07:45:19 +0000, "yices_assert_formula()", "start")
//    (2015-10-27 07:46:12 +0000, "yices_assert_formula()", "finish")
//    (2015-10-27 07:46:12 +0000, "yices_check_context()", "start")
//    (2015-10-27 09:12:30 +0000, "yices_check_context()", "finish")
//    (2015-10-27 09:12:30 +0000, "yices_get_model()", "start")
//    (2015-10-27 09:12:31 +0000, "yices_get_model()", "finish")
//    44575.461 ms parsePath() start  -  parsePath() finish
//    0.465 ms parsePath() finish  -  yices_assert_formula() start
//    52867.222 ms yices_assert_formula() start  -  yices_assert_formula() finish
//    0.192 ms yices_assert_formula() finish  -  yices_check_context() start
//    5178591.118 ms yices_check_context() start  -  yices_check_context() finish
//    0.192 ms yices_check_context() finish  -  yices_get_model() start
//    1063.906 ms yices_get_model() start  -  yices_get_model() finish
//    5277.0985609889 start - finish
//    Test Case '-[NyTermsTests.YicesSatTrials testTryHWV134cnf1]' passed (5277.853 seconds).
    
    /// (inactive) test run
    /// - parse ~ 45 s
    ///     - HWV134-1.p
    ///     - 2_332_428 clauses
    ///     - ~ 4,3 GB RAM
    /// - yices 
    ///     - new context
    ///     - assert formula(e) ~ 53 s
    ///     - check context ~ 5179 s
    ///     - get model ~ 1s
    func testTryHWV134cnf1() {
        let startText = "will start"
        let completionText = "has finished"
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV134-1.p"
        
        var ts = [(NSDate(),"parsePath()",startText)]
        print(ts.last!)
        let (result,tptpFormulae,_) = parsePath(path)
        ts.append((NSDate(),ts.last!.1,completionText))
        print(ts.last!)
        
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(2332428, tptpFormulae.count)
        
        // check
        ts.append((NSDate(),"yices_new_context()",startText))
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        ts.append((NSDate(),ts.last!.1,completionText))
        
        
        ts.append((NSDate(),"yices_assert_formula()",startText))
        print(ts.last!)
        for tptpFormula in tptpFormulae {
            
            let tptpClause = tptpFormula.formula
            let yices_clause = build_yices_term(tptpClause, range_tau:bool_tau)
            
            // XCTAssertEqual(1, yices_term_is_bool(yices_clause),"a yices clause must be bool")
            
            yices_assert_formula(ctx, yices_clause)
        }
        ts.append((NSDate(),ts.last!.1,completionText))
        print(ts.last!)
        
        ts.append((NSDate(),"yices_check_context()",startText))
        print(ts.last!)
        XCTAssertTrue(STATUS_SAT == yices_check_context(ctx, nil))
        ts.append((NSDate(),ts.last!.1,completionText))
        print(ts.last!)
        
        ts.append((NSDate(),"yices_get_model()",startText))
        print(ts.last!)
        let mdl = yices_get_model(ctx, 1);
        defer { yices_free_model(mdl) }
        
        ts.append((NSDate(),ts.last!.1,completionText))
        print(ts.last!)
        
        var d0 = ts.first!
        
        for d1 in ts[1..<ts.count] {
            let d = floor(d1.0.timeIntervalSinceDate(d0.0)*1000_000)/1000.0
            
            print(d,"ms",d0.1,d0.2," - ",d1.1, d1.2)
            
            d0 = d1
        }
        
        print(ts.last!.0.timeIntervalSinceDate(ts.first!.0),startText,"-",completionText)
        
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
