//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

@testable
import NyTerms  // String+Yices

func ~=(lhs:smt_status_t, rhs:smt_status_t) -> Bool {
    return lhs == rhs
}

/// reimplement yices/examples/examples2.c:main()
func example2() -> (type:String?, term:String?, model:String?) {
    var type_string: String? = nil
    var term_string: String? = nil
    var model_string: String? = nil
    
    // Gloabl initialization
    yices_init();
    
    defer {
        // Global cleanup: free all memory used by Yices
        yices_exit()
    }
    
    // Create an uninterpreted term of type real and call it "X"
    
    let real = yices_real_type();
    
    type_string = String(tau:real, width: 120,height: 2,offset: 6)
    
    let t = yices_new_uninterpreted_term(real);
    var code = yices_set_term_name(t, "X");
    
    // If code is negative, something went wrong
    if code < 0 {
        print("Error \(code) in yices_set_term\n")
        yices_print_error(stdout)
        fflush(stdout)
        return (type_string, term_string, model_string) // goto done;
    }
    
    // create the atom (x > 0)
    let a = yices_arith_gt0_atom(t)
    yices_pp_term(stdout, a, 120, 2, 6);
    
    term_string = String(term:a, width: 120,height: 2,offset: 6)
    
    /*
    * Check that (x > 0) is satisfiable and get a model
    * - create a context
    * - assert atom 'a' in this context
    * - check that the context is satisfiable
    */
    
    let ctx = yices_new_context(nil);  // NULL means use the default configuration
    defer {
        yices_free_context(ctx)
    }
    
    
    code = yices_assert_formula(ctx, a);
    if (code < 0) {
        print("Assert failed: ");
        yices_print_error(stdout);
        fflush(stdout);
        return (type_string, term_string, model_string) // goto done;
    }
    
    switch (yices_check_context(ctx, nil)) { // NULL means default heuristics
    case STATUS_SAT:
        // build the model and print it
        print("Satisfiable\n");
        let mdl = yices_get_model(ctx, 1); // 1 == true
        code = yices_pp_model(stdout, mdl, 120, 100, 0);
        if (code < 0) {
            print("Print model failed: ");
            yices_print_error(stdout);
            fflush(stdout);
            return (type_string, term_string, model_string) // goto done;
        }
        model_string = String(model:mdl, width: 120,height: 100,offset: 6)
        
        // cleanup: delete the model
        yices_free_model(mdl);
        break;
        
    case STATUS_UNSAT:
        print("Unsatisfiable\n");
        break;
        
    case STATUS_UNKNOWN:
        print("Status is unknown\n");
        break;
        
    case STATUS_IDLE:
        fallthrough
    case STATUS_SEARCHING:
        fallthrough
    case STATUS_INTERRUPTED:
        fallthrough
    case STATUS_ERROR:
        fallthrough
    default:
        // these codes should not be returned
        print("Bug: unexpected status returned\n");
        break;
    }
    
    return (type_string, term_string, model_string)
}

