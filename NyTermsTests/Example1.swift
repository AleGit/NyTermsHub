//
//  Example1.swift
//  NyTerms
//
//  Created by Alexander Maringele on 04.07.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class Example1: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        yices_init()

    }
    
    override func tearDown() {
        yices_exit()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func print_term(term : term_t) {
        guard let string = String(term:term) else {
            print(stderr, "Error in print_term: ");
            yices_print_error(stderr);
            // exit(1);
            return
        }
        print(string)
    }
    
    /// yices/examples/examples1.c:simple_test()
    func testSimpleTest() {
        var code : Int32 = 0;
        
        /*
         * Build the formula
         */
        // Create two uninterpreted terms of type int.
        let int_type = yices_int_type();
        let x = yices_new_uninterpreted_term(int_type);
        let y = yices_new_uninterpreted_term(int_type);
        
        // Assign names "x" and "y" to these terms.
        // This is optional, but we need the names in yices_parse_term
        // and it makes pretty printing nicer.
        yices_set_term_name(x, "x");
        yices_set_term_name(y, "y");
        
        let arg1 = yices_arith_geq0_atom(x) // x >= 0
        let arg2 = yices_arith_geq0_atom(y) // y >= 0
        let arg3 = yices_arith_eq_atom(yices_add(x, y), yices_int32(100))  // x + y = 100
        
        // Build the formula (and (>= x 0) (>= y 0) (= (+ x y) 100))
        let f = yices_and3(arg1,arg2,arg3)
        
        // Another way to do it
        // term_t f_var = yices_parse_term("(and (>= x 0) (>= y 0) (= (+ x y) 100))");
        
        let f_var = yices_parse_term("(and (>= x 0) (>= y 0) (= (+ x y) 0))");
        
        /*
         * Print the formulas: f and f_var should be identical
         */
        print("Formula f");
        print_term(f);
        print("Formula f_var");
        print_term(f_var);
        
        
        /*
         * To check whether f is satisfiable
         * - first build a context
         * - assert f in the context
         * - call check_context
         * - if check_context returns SAT, build a model
         *   and make queries about the model.
         */
        let ctx = yices_new_context(nil);  // NULL means 'use default configuration'
        defer {
            yices_free_context(ctx);   // delete the context
        }
        
        code = yices_assert_formula(ctx, f);
        if (code < 0) {
            print(stderr, "Assert failed: code = \(code), error = \(yices_error_code())");
            yices_print_error(stderr);
        }
        
        let status = yices_check_context(ctx, nil)
        XCTAssertEqual(status, STATUS_SAT)
        
        switch status { // call check_context, NULL means 'use default heuristics'
        case STATUS_SAT:
            print("The formula is satisfiable");
            let model = yices_get_model(ctx, 1);  // get the model
            defer {
                yices_free_model(model); // clean up: delete the model
            }
            if (model == nil) {
                print(stderr, "Error in get_model")
                yices_print_error(stderr);
            } else {
                print("Model");
                code = yices_pp_model(stdout, model, 80, 4, 0); // print the model
                
                var v : Int32 = 0;
                code = yices_get_int32_value(model, x, &v);   // get the value of x, we know it fits int32
                if (code < 0) {
                    print(stderr, "Error in get_int32_value for 'x'");
                    yices_print_error(stderr);
                } else {
                    print("Value of x = \(v)");
                }
                
                code = yices_get_int32_value(model, y, &v);   // get the value of y
                if (code < 0) {
                    print(stderr, "Error in get_int32_value for 'y'");
                    yices_print_error(stderr);
                } else {
                    print("Value of y = \(v)");
                }
                
                
            }
            
        case STATUS_UNSAT:
            print("The formula is not satisfiable")
            
        case STATUS_UNKNOWN:
            print("The status is unknown");
            
        case STATUS_IDLE,
             STATUS_SEARCHING,
             STATUS_INTERRUPTED,
             STATUS_ERROR:
            print(stderr, "Error in check_context")
            yices_print_error(stderr);
        default:
            print(stderr, "Unknonw status in check_context")
        }
    }
    
}
