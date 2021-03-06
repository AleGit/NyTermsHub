//
//  YicesNodeTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class YicesNodeTests: YicesTestCase {
    
    func testTerms() {
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        let variables : [TptpNode] = ["X", "a", "Y", "a", "f(X)", "f(a)", "f(Y)" ]
        
        let ts = variables.map { Yices.term($0) }
        
        var t = ts[0] // "X"
        XCTAssertEqual(yices_term_num_children(t),0)
        
        XCTAssertNotEqual(ts[0], ts[1])
        XCTAssertEqual(ts[0], ts[2])
        XCTAssertNotEqual(ts[0], ts[3])
        XCTAssertNotEqual(ts[0], ts[4])
        XCTAssertNotEqual(ts[0], ts[5])
        XCTAssertNotEqual(ts[0], ts[6])
        
        t = ts[1] // "a"
        XCTAssertEqual(yices_term_num_children(t),0)
        
        XCTAssertNotEqual(t, ts[2])
        XCTAssertEqual(t, ts[3])
        XCTAssertNotEqual(t, ts[4])
        XCTAssertNotEqual(t, ts[5])
        XCTAssertNotEqual(t, ts[6])
        
        t = ts[2] // "Y"
        XCTAssertEqual(yices_term_num_children(t),0)
        
        XCTAssertNotEqual(t, ts[3])
        XCTAssertNotEqual(t, ts[4])
        XCTAssertNotEqual(t, ts[5])
        XCTAssertNotEqual(t, ts[6])
        
        t = ts[3] // "a"
        XCTAssertEqual(yices_term_num_children(t),0)
        
        XCTAssertNotEqual(t, ts[4])
        XCTAssertNotEqual(t, ts[5])
        XCTAssertNotEqual(t, ts[6])
        
        t = ts[4] // "f(X)"
        XCTAssertEqual(yices_term_num_children(t),2)
        
        XCTAssertEqual(yices_term_child(t,1),ts[0])
        
        XCTAssertNotEqual(t, ts[5])
        XCTAssertEqual(t, ts[6])
        
        t = ts[5] // "f(a)"
        XCTAssertEqual(yices_term_num_children(t),2)
        XCTAssertEqual(yices_term_child(t,1),ts[1])
        
        XCTAssertNotEqual(ts[5], ts[6])
        
        t = ts[6] // "f(Y)"
        XCTAssertEqual(yices_term_num_children(t),2)
        XCTAssertEqual(yices_term_child(t,1),ts[0])
        
        
        print(ts)
        
    }
    
    func testPropositionalTrue() {
        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)
        }
        
        let wahr = "p|~p" as TptpNode
        let (t,_,_) = Yices.clause(wahr)
        XCTAssertEqual(t,Yices.top)
        
        yices_check_context(ctx, nil)
        XCTAssertEqual(STATUS_SAT, yices_context_status(ctx))
        
        let mdl = yices_get_model(ctx, 1)
        defer {
            yices_free_model(mdl)
        }
        
        print(String(model:mdl)!)
        
    }
    
    func testPredicateTrue() {
        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)
        }
        
        let wahr = "p(X)|~p(X)" as TptpNode
        let (t,_,_) = Yices.clause(wahr)
        XCTAssertEqual(t,Yices.top)

        yices_assert_formula(ctx, t)
        
        yices_check_context(ctx, nil)
        XCTAssertEqual(STATUS_SAT, yices_context_status(ctx))
        
        let mdl = yices_get_model(ctx, 1)
        defer {
            yices_free_model(mdl)
        }
        
        print(String(model:mdl)!)
        
        
    }
    
    func testEmptyClause() {
        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)
        }
        let empty = TptpNode(connective:"|",nodes: [TptpNode]())
        let (t,_,_) = Yices.clause(empty)
        yices_assert_formula(ctx, t)
        yices_check_context(ctx, nil)
        XCTAssertEqual(STATUS_UNSAT, yices_context_status(ctx))
        
    }

    func testPropositionalFalse() {
        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)
        }
        
        for clause in [
            TptpNode(connective:"|", nodes:[ "p" as TptpNode]),
            TptpNode(connective:"|", nodes:[ "~p" as TptpNode])] {
                let (t,_,_) = Yices.clause(clause)
                yices_assert_formula(ctx, t)
        }
        yices_check_context(ctx, nil)
        XCTAssertEqual(STATUS_UNSAT, yices_context_status(ctx))
    }
    
    
    
    func testPredicateFalse() {
        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)
        }
        
        for clause in [
            TptpNode(connective:"|", nodes:[ "p(X)" as TptpNode]),
            TptpNode(connective:"|", nodes:[ "~p(Y)" as TptpNode])] {
                let (t,_,_) = Yices.clause(clause)
                yices_assert_formula(ctx, t)
        }
        yices_check_context(ctx, nil)
        XCTAssertEqual(STATUS_UNSAT, yices_context_status(ctx))
    }
    
    func testPropositionalSatisfiable() {
        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)
        }
        
        for clause in [
            TptpNode(connective:"|", nodes:[ "p" as TptpNode])] {
                let (t,_,_) = Yices.clause(clause)
                yices_assert_formula(ctx, t)
        }
        yices_check_context(ctx, nil)
        XCTAssertEqual(STATUS_SAT, yices_context_status(ctx))
    }
    
    func testPredicateSatisfiable() {
        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)
        }
        
        for clause in [
            TptpNode(connective:"|", nodes:[ "p(X)" as TptpNode])] {
                let (t,_,_) = Yices.clause(clause)
                yices_assert_formula(ctx, t)
        }
        yices_check_context(ctx, nil)
        XCTAssertEqual(STATUS_SAT, yices_context_status(ctx))
    }
    
    func testSubterms() {
        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)
        }
        
        let term = "p(X,f(X),f(f(X)),f(f(X)))" as TptpNode
        
        var pairs = [ (TptpNode, term_t)]()
        
        for t in [ term, "Z", "f(Y)" ]{
            pairs.append((t,Yices.term(t)))
            
        }
        
        for subterm in  term.subterms {
            
            pairs.append((subterm,Yices.term(subterm)))
            
        }
        
        for outer in pairs {
            pairs.removeFirst()
            
            for inner in pairs {
                XCTAssertTrue(outer.0 != inner.0 || outer.1==inner.1)
                if outer.1 == inner.1 {
                    print(outer==inner,outer,inner)
                }
            }
        }
    }
    

    
    func testPUZ001() {
        let path = "PUZ001-1".p!
        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)
        }
        let clauses = TptpNode.roots(path)
        for clause in clauses {
            let (t,_,_) = Yices.clause(clause)
            yices_assert_formula(ctx, t)
        }
        yices_check_context(ctx, nil)
        XCTAssertEqual(STATUS_SAT, yices_context_status(ctx))
    }
    
}
