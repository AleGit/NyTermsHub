//
//  Z3CapiTest.swift
//  NyTerms
//
//  Created by Alexander Maringele on 24.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest

class Z3CapiTest: XCTestCase {

    func testZ3CapiMain() {
        z3_main()
    }
    
    /// see z3_capi.c
    private func mk_solver(_ ctx:Z3_context) -> Z3_solver{
        let s = Z3_mk_solver(ctx)
        Z3_solver_inc_ref(ctx, s)
        return s
    }
    
    /// see z3_capi.c
    private func del_solver(_ ctx:Z3_context, _ s: Z3_solver)
    {
        Z3_solver_dec_ref(ctx, s);
    }
    
    /// see z3_capi.c # demorgan()
    func testDeMorgan() {
        
        let cfg = Z3_mk_config()        // make (default) configuration
        let ctx = Z3_mk_context(cfg)    // make context with configuration
        defer { Z3_del_context(ctx) }   // delete context at end of scope
        Z3_del_config(cfg) // delete configuration (no need for delay)
        
        let bool_sort          = Z3_mk_bool_sort(ctx);
        let symbol_x           = Z3_mk_int_symbol(ctx, 0);
        let symbol_y           = Z3_mk_int_symbol(ctx, 1);
        let x                  = Z3_mk_const(ctx, symbol_x, bool_sort);
        let y                  = Z3_mk_const(ctx, symbol_y, bool_sort);
        
        /* De Morgan - with a negation around */
        /* !(!(x && y) <-> (!x || !y)) */
        let not_x              = Z3_mk_not(ctx, x);
        let not_y              = Z3_mk_not(ctx, y);
        
        let x_and_y            = Z3_mk_and(ctx, 2, [x,y]);
        let ls                 = Z3_mk_not(ctx, x_and_y);
        
        let rs                 = Z3_mk_or(ctx, 2, [not_x, not_y]);
        let conjecture         = Z3_mk_iff(ctx, ls, rs);
        let negated_conjecture = Z3_mk_not(ctx, conjecture);
        
        let s = mk_solver(ctx);         // make solver
        defer { del_solver(ctx,s) }     // delete solver at end of scope
        
        
        Z3_solver_assert(ctx, s, negated_conjecture);
        
        let status = Z3_solver_check(ctx,s)
        
        XCTAssertEqual(Z3_L_FALSE, status)
        
        switch status {
            case Z3_L_FALSE: // -1
                /* The negated conjecture was unsatisfiable, hence the conjecture is valid */
            print("DeMorgan is valid. :-)")
        case Z3_L_UNDEF: // 0
            print("DeMorgan is undefined? :-/")
        case Z3_L_TRUE: // 1
            /* The negated conjecture was satisfiable, hence the conjecture is not valid */
            print("DeMorgan is not valid. :-(")
        default:
            print("DeMorgan is unknown? :-\\")
            
        }
        
        
    }

}
