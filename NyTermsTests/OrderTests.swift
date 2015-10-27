//
//  OrderTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 07.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
import NyTerms

class OrderTests: XCTestCase {

    private typealias T = NodeStruct
    
    func testSimpleLPO() {
        let signature = Set(["+","×","s"])
        func myp(l:Symbol, r:Symbol) -> Bool {
            guard l != r else { return false }
            
            XCTAssertTrue(signature.contains(l))
            XCTAssertTrue(signature.contains(r))
            
            switch (l,r) {
            case ("×", _): return true  // mulitply has highest precedence
            case (_,"s"): return true   // s has lowest precedence
            default: return false
            }
        }
        let lpo = LexicographicPathOrder(p: myp)
        
        let O = T(constant:"0")
        let x = T(variable:"x")
        let y = T(variable:"y")
        
        let Opx = T(function:"+", nodes:[O,x])
        // 0+x > x
        XCTAssertTrue(lpo.greaterThan(Opx, t: x))
        
        let Omx = T(function:"×", nodes:[O,x])
        // 0*x > x
        XCTAssertTrue(lpo.greaterThan(Omx, t: x))
        
        let sx = T(function:"s", nodes:[x])
        // s(x) > x
        XCTAssertTrue(lpo.greaterThan(sx, t: x))
        
        let sx_p_y = T(function:"+", nodes:[sx,y])
        // s(x)+y > y
        XCTAssertTrue(lpo.greaterThan(sx_p_y, t: y))
        
        let xpy = T(function:"+", nodes:[x,y])
        // s(x)+y > x+y
        XCTAssertTrue(lpo.greaterThan(sx_p_y, t: xpy))
        
        let s_xpy = T(function:"s", nodes:[xpy])
        // s(x)+y > s(x+y)
        XCTAssertTrue(lpo.greaterThan(sx_p_y, t: s_xpy))
        
        let sx_m_y = T(function:"×",nodes:[sx,y])
        let xmy = T(function:"×", nodes:[x,y])
        // s(x)*y > x*y
        XCTAssertTrue(lpo.greaterThan(sx_m_y, t: xmy))
        // s(x)+y > x + y
        XCTAssertTrue(lpo.greaterThan(sx_p_y, t: xpy))
        
        // s(x)*y > y
        XCTAssertTrue(lpo.greaterThan(sx_m_y, t: y))
        
        let xmy_p_y = T(function:"+", nodes:[xmy,y])
        // s(x)*y > x*y + y
        XCTAssertTrue(lpo.greaterThan(sx_m_y, t: xmy_p_y))
        
    }
    
    func testWeight() {
        let w : weight = ( w:{ (s:Symbol) -> Int in return s.hashValue }, w0:1)
        XCTAssertEqual(w.w("f"),"f".hashValue)
        XCTAssertEqual(w.w0,1)
    }

}
