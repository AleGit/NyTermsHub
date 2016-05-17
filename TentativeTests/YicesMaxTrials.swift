//
//  YicesMaxTrials.swift
//  NyTerms
//
//  Created by Alexander Maringele on 09.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class YicesMaxTrials: YicesTestCase {

    func testMaxXsmallerAsFive() {

        let ctx = yices_new_context(nil)
        defer {
            yices_free_context(ctx)        }
        
        let x = Yices.typedSymbol("x", term_tau:Yices.int_tau)
        let y = Yices.typedSymbol("y", term_tau:Yices.int_tau)
        let sum = yices_add(x,y)
        
        let five = yices_int64(250)
        
        yices_assert_formula(ctx, yices_arith_lt_atom(sum, five))
        yices_assert_formula(ctx, yices_arith_lt_atom(x, y))
        
        yices_check_context(ctx, nil)
        let mdl = yices_get_model(ctx, 1)
        defer {
            yices_free_model(mdl)
        }
        
        let xval  = Yices.getValue(x, mdl: mdl) as Int32?
        let yval = Yices.getValue(y, mdl: mdl) as Int32?
        let sval = Yices.getValue(sum, mdl: mdl) as Int32?
        print(xval,yval,sval)
        
       
        
        
        
    }

}
