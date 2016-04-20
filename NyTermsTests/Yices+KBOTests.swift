//
//  Yices+KBOTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 19.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class YicesKBOTests: XCTestCase {

    override func setUp() {
        super.setUp()
        yices_init()
    }
    
    override func tearDown() {
        yices_exit()
        super.tearDown()
    }
    
    func printValues(ctx: COpaquePointer, terms: [term_t])  {
        XCTAssertEqual(STATUS_SAT, yices_check_context(ctx, nil))
        
        let mdl = yices_get_model(ctx, 1)
        defer {
            yices_free_model(mdl)
        }
        
        for t in terms {
            if let s = String(term:t) {
                var val : Int32 = 0
                if yices_get_int32_value(mdl, t, &val) == 0 {
                    print(s,val)
                } else {
                    print(s, "yices_get_int32_value(mdl,\(s),&val) failed.")
                    continue
                }
                
            }
        }
        
    }
    
    func printTerms(ctx: COpaquePointer, terms: [(TptpNode,term_t)])  {
        XCTAssertEqual(STATUS_SAT, yices_check_context(ctx, nil))
        
        let mdl = yices_get_model(ctx, 1)
        defer {
            yices_free_model(mdl)
        }
        
        for (node,t) in terms {
            if let s = String(term:t) {
                var val : Int32 = 0
                if yices_get_int32_value(mdl, t, &val) == 0 {
                    print("weight(\(node)) = \(val)")
                } else {
                    print(s, "yices_get_int32_value(mdl,\(s),&val) failed.")
                    continue
                }
                
            }
        }
        
    }
    
    func testEmpty() {
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        
        let kbo = Yices.KBO()
        let adm = kbo.admissible
        XCTAssertEqual("(< (* -1 𝛚₀) 0)",String(term:adm)!) // -𝛚₀ < 0, i.e. 𝛚₀ > 0
        
        yices_assert_formula(ctx, adm)
        print(ctx, kbo.atoms)
    }
    
    func test_FX_c() {
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        let fX = "f(X)" as TptpNode
        let c = "c" as TptpNode
        var kbo = Yices.KBO()
        
        let lr = kbo.leftRightCondition(fX, c)
        let rl = kbo.leftRightCondition(c,fX)
        let adm = kbo.admissible
        
        XCTAssertEqual("(and (< (* -1 𝛚₀) 0) (=> (= w⏑f 0) (>= (+ (* -1 p⏑f) p⏑c) 0)) (and (>= w⏑f 0) (>= (+ (* -1 𝛚₀) w⏑c) 0)))", String(term:adm)!)
        XCTAssertEqual("(=> (>= (+ (* -1 𝛚₀) (* -1 w⏑f) w⏑c) 0) (and (= (+ 𝛚₀ w⏑f (* -1 w⏑c)) 0) (< (+ (* -1 p⏑f) p⏑c) 0)))", String(term:lr)!)
        XCTAssertEqual("false", String(term:rl)!)
        
        yices_assert_formula(ctx, lr)
        yices_assert_formula(ctx, adm)
        
        print(fX,"=",c)
        printValues(ctx, terms: kbo.atoms)

    }
    
    
    func test_Fc_c() {
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        let fc = "f(c)" as TptpNode
        let c = "c" as TptpNode
        var kbo = Yices.KBO()
        
        let lr = kbo.leftRightCondition(fc, c)
        let rl = kbo.leftRightCondition(c,fc)
        let adm = kbo.admissible
        
        XCTAssertEqual("(and (=> (= w⏑f 0) (>= (+ (* -1 p⏑f) p⏑c) 0)) (< (* -1 𝛚₀) 0) (and (>= w⏑f 0) (>= (+ (* -1 𝛚₀) w⏑c) 0)))", String(term:adm)!)
        XCTAssertEqual("(=> (>= (* -1 w⏑f) 0) (and (= w⏑f 0) (< (+ (* -1 p⏑f) p⏑c) 0)))", String(term:lr)!)
        XCTAssertEqual("(=> (>= w⏑f 0) (and (= w⏑f 0) (< (+ p⏑f (* -1 p⏑c)) 0)))", String(term:rl)!)
        
        yices_assert_formula(ctx, lr)
        yices_assert_formula(ctx, adm)
        
        print(fc,"=",c)
        printValues(ctx, terms: kbo.atoms)
    }
    
    func test_FX_X() {
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        let fX = "f(X)" as TptpNode
        let X = "X" as TptpNode
        var kbo = Yices.KBO()
        
        let lr = kbo.leftRightCondition(fX, X)
        let rl = kbo.leftRightCondition(X,fX)
        let adm = kbo.admissible
        
        XCTAssertEqual("(and (< (* -1 𝛚₀) 0) (>= w⏑f 0))", String(term:adm)!)
        XCTAssertEqual("(=> (>= (* -1 w⏑f) 0) (= w⏑f 0))", String(term:lr)!)
        XCTAssertEqual("false", String(term:rl)!)
        
    
        yices_assert_formula(ctx, lr)
        yices_assert_formula(ctx, adm)
        
        print(fX,"=",X)
        printValues(ctx, terms: kbo.atoms)
    }
    
    func testE435() {
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        var kbo = Yices.KBO()
        
        let trs : [(TptpNode,TptpNode)] = [
            ("gg(o)",       "o"),
            ("gg(s(X))",    "p(gg(X))"),
            ("gg(p(X))",   "s(gg(X))"),
            
            ("sub(X,o)","X"),
            ("sub(X,s(Y))","p(sub(X,Y))"),
            ("sub(X,p(Y))","s(sub(X,Y))"),
            
            ("s(p(X))","X"),
            ("p(s(X))","X"),
            ("add(X,Y)","sub(X,gg(Y))")]
        
        var weights = [(TptpNode,term_t)]()
        
        for (s,t) in trs {
            let c = kbo.leftRightCondition(s, t)
            weights.append((s,kbo.weight(s)))
            weights.append((t,kbo.weight(t)))
            yices_assert_formula(ctx, c)
            print(s,"=",t,"\t",String(term:c)!)
        }
        
        yices_assert_formula(ctx, kbo.admissible)
        
        printValues(ctx, terms: kbo.atoms)
        printTerms(ctx, terms: weights)
        

    }

}
