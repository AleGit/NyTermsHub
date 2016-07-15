//
//  OrderTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 07.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
@testable
import NyTerms

class OrderTests: XCTestCase {

    private typealias T = NodeStruct
    
    func testSimpleLPO() {
        let signature = Set(["+","×","s"])
        func myp(_ l:String, r:String) -> Bool {
            guard l != r else { return false }
            
            XCTAssertTrue(signature.contains(l))
            XCTAssertTrue(signature.contains(r))
            
            switch (l,r) {
            case ("×", _): return true  // mulitply has highest precedence
            case (_,"s"): return true   // s has lowest precedence
            default: return false
            }
        }
        let lpo = LexicographicPathOrder<T>(p: myp)
        
        let O = T(stringLiteral:"0")
        let x = T(stringLiteral:"x")
        let y = T(stringLiteral:"y")
        
        let Opx = T(symbol:"+", nodes:[O,x])
        // 0+x > x
        XCTAssertTrue(lpo.greaterThan(Opx, t: x))
        
        let Omx = T(symbol:"×", nodes:[O,x])
        // 0*x > x
        XCTAssertTrue(lpo.greaterThan(Omx, t: x))
        
        let sx = T(symbol:"s", nodes:[x])
        // s(x) > x
        XCTAssertTrue(lpo.greaterThan(sx, t: x))
        
        let sx_p_y = T(symbol:"+", nodes:[sx,y])
        // s(x)+y > y
        XCTAssertTrue(lpo.greaterThan(sx_p_y, t: y))
        
        let xpy = T(symbol:"+", nodes:[x,y])
        // s(x)+y > x+y
        XCTAssertTrue(lpo.greaterThan(sx_p_y, t: xpy))
        
        let s_xpy = T(symbol:"s", nodes:[xpy])
        // s(x)+y > s(x+y)
        XCTAssertTrue(lpo.greaterThan(sx_p_y, t: s_xpy))
        
        let sx_m_y = T(symbol:"×",nodes:[sx,y])
        let xmy = T(symbol:"×", nodes:[x,y])
        // s(x)*y > x*y
        XCTAssertTrue(lpo.greaterThan(sx_m_y, t: xmy))
        // s(x)+y > x + y
        XCTAssertTrue(lpo.greaterThan(sx_p_y, t: xpy))
        
        // s(x)*y > y
        XCTAssertTrue(lpo.greaterThan(sx_m_y, t: y))
        
        let xmy_p_y = T(symbol:"+", nodes:[xmy,y])
        // s(x)*y > x*y + y
        XCTAssertTrue(lpo.greaterThan(sx_m_y, t: xmy_p_y))
        
    }
    
    func testWeight() {
        let w : weight = ( w:{ (s:String) -> Int in return s.hashValue }, w0:1)
        XCTAssertEqual(w.w("f"),"f".hashValue)
        XCTAssertEqual(w.w0,1)
    }

}
