//
//  Yices+LPOTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 20.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class YicesLPOTests: YicesTestCase {
    
    func testE435() {
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        var lpo = Yices.LPO()
        
        let trs : [(TptpNode,TptpNode)] = [
            ("add(o,Y)", "Y"),
            ("add(s(X),Y)", "s(add(X,Y))"),
            ("mul(o,Y)", "o"),
            ("mul(s(X),Y)", "add(mul(X,Y),Y)"),
            ]
        
        for (s,t) in trs {
            let c = lpo.leftRightCondition(s, t)
            
            yices_assert_formula(ctx, c)
            print(s,">",t,"\t ⬄ \t",String(term:c)!)
        }
        
        XCTAssertEqual(STATUS_SAT,yices_check_context(ctx, nil))
        
        let mdl = yices_get_model(ctx, 1)
        defer {
            yices_free_model(mdl)
        }
        
        let precedences = lpo.precedences.map {
            (t) -> (String,Int32) in
            let f = String(term:t)!
            var p : Int32 = -1
            
            if yices_get_int32_value(mdl, t, &p) == 0 {
                return(f,p)
            } else {
                print(f, "yices_get_int32_value(mdl,\(f),&val) failed.")
                return(f,-1)
            }
            
            }.sort {
                $0.1 > $1.1
        }
        
        print (precedences)
    }

}
