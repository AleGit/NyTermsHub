//
//  PolyTryTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 20.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
@testable
import NyTerms

class PolyTryTests: YicesTestCase {
    
    
    

    
    private func poly<T:Node where T.Symbol == String>(t:T) -> String {
        guard let nodes = t.nodes else { return t.symbol } // variable
        
        let args = nodes.map { poly($0) }
        
        
        switch t.symbol {
        case "0", "1" where args.count == 0:
            return "0"
            
        case "xor" where args.count == 2:
            return "(\(args[0])+\(args[1])+2)"
            
        case "mult" where args.count == 2:
            let ax = args[0]
            let ay = args[1]
            return "(2*\(ax)*\(ay)+2*\(ax)+2*\(ay)+1)"
            
        case "plus" where args.count == 2:
            let ax = args[0]
            let ay = args[1]
            return "(2*\(ax)*\(ay)+3*\(ax)+3*\(ay)+6)"
            
        case "not" where args.count == 1:
            let ax = args[0]
            return "(\(ax)+3)"
            
            
        default:
            return "UNDEFINED"
            
        }
    }
    
    func test_HW_2_1_d() {
        let t = "plus(mult(X,Y),xor(Y,mult(X,Z)))" as TestNode
        XCTAssertTrue(t.isTerm)
        
        let l1 = "plus(X,Y)" as TestNode
        XCTAssertEqual("(2*X*Y+3*X+3*Y+6)", poly(l1))
        
        let r1 = "xor(xor(X,Y),mult(X,Y))" as TestNode
        XCTAssertEqual("((X+Y+2)+(2*X*Y+2*X+2*Y+1)+2)", poly(r1))
        
        let l2 = "not(X)" as TestNode
        let r2 = "xor(X,1)" as TestNode
        XCTAssertEqual("(X+3)", poly(l2))
        XCTAssertEqual("(X+0+2)", poly(r2))
        
        let l3 = "mult(xor(X,Y),Z)" as TestNode
        let r3 = "xor(mult(X,Z),mult(Y,Z))" as TestNode
        XCTAssertEqual("(2*(X+Y+2)*Z+2*(X+Y+2)+2*Z+1)", poly(l3))
        XCTAssertEqual("((2*X*Z+2*X+2*Z+1)+(2*Y*Z+2*Y+2*Z+1)+2)", poly(r3))
        
        let l4 = "mult(1,X)" as TestNode
        let r4 = "X" as TestNode
        XCTAssertEqual("(2*0*X+2*0+2*X+1)", poly(l4))
        XCTAssertEqual("X", poly(r4))
        
        let l5 = "xor(X,X)" as TestNode
        let r5 = "0" as TestNode
        XCTAssertEqual("(X+X+2)", poly(l5))
        XCTAssertEqual("0", poly(r5))
        
        let l6 = "mult(X,X)" as TestNode
        let r6 = "X" as TestNode
        XCTAssertEqual("(2*X*X+2*X+2*X+1)", poly(l6))
        XCTAssertEqual("X", poly(r6))
        
        let l7 = "xor(0,X)" as TestNode
        let r7 = "X" as TestNode
        XCTAssertEqual("(0+X+2)", poly(l7))
        XCTAssertEqual("X", poly(r7))
        
        let l8 = "mult(0,X)" as TestNode
        let r8 = "0" as TestNode
        XCTAssertEqual("(2*0*X+2*0+2*X+1)", poly(l8))
        XCTAssertEqual("0", poly(r8))
    }
    
    func testPolyYices() {

        let yices_int = Yices.int_tau
        
        let x = yices_new_uninterpreted_term(yices_int)
        guard Yices.check(yices_set_term_name(x, "X"), label:"\(#function)") else { XCTFail(); return }
        let y = yices_new_uninterpreted_term(yices_int)
        guard Yices.check(yices_set_term_name(y, "Y"), label:"\(#function)") else { XCTFail(); return }
        let z = yices_new_uninterpreted_term(yices_int)
        guard Yices.check(yices_set_term_name(z, "Z"), label:"\(#function)") else { XCTFail(); return }
        
        let sum = yices_add(x, y)
        let pro = yices_mul(x, y)
        
        
        print(String(term:sum)!)
        print(String(term:pro)!)
        
    }
    
    private func polyices<T:Node where T.Symbol == String>(t:T) -> term_t {
        guard let nodes = t.nodes else {
            var v = yices_get_term_by_name(t.symbol)
            if v == NULL_TERM {
                v = yices_new_uninterpreted_term(Yices.int_tau)
                yices_set_term_name(v, t.symbol)            }
            return v
        } // variable
        
        let args = nodes.map { polyices($0) }
        
        
        switch t.symbol {
        case "0", "1" where args.count == 0:
            return yices_zero()
            
        case "xor" where args.count == 2:
            // x+y+2
            return yices_sum(3,[args[0], args[1], yices_int64(2)])
            
        case "mult" where args.count == 2:
            let ax = args[0]
            let ay = args[1]
            // 2xy+2x+2y+1
            
            return yices_sum(4, [yices_product(3, [yices_int64(2),ax,ay,yices_int64(1)]),yices_mul(yices_int64(2), ax),yices_mul(yices_int64(2),ay), yices_int64(1)])
            
            
            
        case "plus" where args.count == 2:
            
            let ax = args[0]
            let ay = args[1]
            
            // 2xy+3x+3y+6
            let result = yices_sum(4,[
                yices_product(3,[yices_int64(2),ax,ay]),
                yices_mul(yices_int64(3), ax),
                yices_mul(yices_int64(3), ay),
                yices_int64(6) ])
                return result
            
        case "not" where args.count == 1:
            // x+3
            let ax = args[0]
            return yices_add(ax,yices_int64(2))
            
            
        default:
            return NULL_TERM
            
        }
    }
    
    func test_HW_2_1_d_yices() {
        

        let t = "plus(mult(X,Y),xor(Y,mult(X,Z)))" as TestNode
        XCTAssertTrue(t.isTerm)
        
        let l1 = "plus(X,Y)" as TestNode
        XCTAssertEqual("(+ 6 (* 3 X) (* 3 Y) (* 2 X Y))", String(term:polyices(l1)))
        
        
        XCTAssertEqual("X", String(term:yices_get_term_by_name("X")))
        XCTAssertEqual("Y", String(term:yices_get_term_by_name("Y")))
        
        
//        let r1 = "xor(xor(X,Y),mult(X,Y))" as TestNode
//        XCTAssertEqual("((X+Y+2)+(2*X*Y+2*X+2*Y+1)+2)", poly(r1))
//        
//        let l2 = "not(X)" as TestNode
//        let r2 = "xor(X,1)" as TestNode
//        XCTAssertEqual("(X+3)", poly(l2))
//        XCTAssertEqual("(X+0+2)", poly(r2))
//        
//        let l3 = "mult(xor(X,Y),Z)" as TestNode
//        let r3 = "xor(mult(X,Z),mult(Y,Z))" as TestNode
//        XCTAssertEqual("(2*(X+Y+2)*Z+2*(X+Y+2)+2*Z+1)", poly(l3))
//        XCTAssertEqual("((2*X*Z+2*X+2*Z+1)+(2*Y*Z+2*Y+2*Z+1)+2)", poly(r3))
//        
//        let l4 = "mult(1,X)" as TestNode
//        let r4 = "X" as TestNode
//        XCTAssertEqual("(2*0*X+2*0+2*X+1)", poly(l4))
//        XCTAssertEqual("X", poly(r4))
//        
//        let l5 = "xor(X,X)" as TestNode
//        let r5 = "0" as TestNode
//        XCTAssertEqual("(X+X+2)", poly(l5))
//        XCTAssertEqual("0", poly(r5))
//        
//        let l6 = "mult(X,X)" as TestNode
//        let r6 = "X" as TestNode
//        XCTAssertEqual("(2*X*X+2*X+2*X+1)", poly(l6))
//        XCTAssertEqual("X", poly(r6))
//        
//        let l7 = "xor(0,X)" as TestNode
//        let r7 = "X" as TestNode
//        XCTAssertEqual("(0+X+2)", poly(l7))
//        XCTAssertEqual("X", poly(r7))
//        
//        let l8 = "mult(0,X)" as TestNode
//        let r8 = "0" as TestNode
//        XCTAssertEqual("(2*0*X+2*0+2*X+1)", poly(l8))
//        XCTAssertEqual("0", poly(r8))
    }
    
}
