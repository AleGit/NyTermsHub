//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

public struct Yi {
    
    class Context {
        
        private var ctx : COpaquePointer
        
        init() {
            ctx = yices_new_context(nil)
        }
        
        deinit {
            yices_free_context(ctx)
        }
    }
    
    final class TptpContext : Context {
        
        private var free_tau = yices_int_type()
        private var bool_tau = yices_bool_type()
        private var global_constant : term_t = NULL_TERM
        
        override init() {
            super.init()
            global_constant = yices_new_uninterpreted_term(free_tau)
            yices_set_term_name(global_constant, "⊥")
        }
        
        
        func build_yices_term<N:Node>(term:N, range_tau:type_t) -> term_t {
            
            // map all variables to global distinc constant '⊥'
            guard let nodes = term.nodes else { return global_constant }
            
            switch term.symbol {
            case "~":
                assert(nodes.count == 1)
                return yices_not( build_yices_term(nodes.first!, range_tau:bool_tau))
                
            case "|":
                var args = nodes.map { build_yices_term($0, range_tau: bool_tau) }
                return yices_or( UInt32(nodes.count), &args)
                
            case "&":
                var args = nodes.map { build_yices_term($0, range_tau: bool_tau) }
                return yices_and( UInt32(nodes.count), &args)
                
            case "!=":
                assert(nodes.count == 2)
                let args = nodes.map { build_yices_term($0, range_tau: free_tau) }
                return yices_neq(args.first!,args.last!)
                
            case "=":
                assert(nodes.count == 2)
                let args = nodes.map { build_yices_term($0, range_tau: free_tau) }
                return yices_eq(args.first!,args.last!)
                
            default:
                
                var t = yices_get_term_by_name(term.symbol)     // constant c, function f
                
                if t == NULL_TERM {
                    if nodes.count == 0 {
                        // proposition or (function) constant
                        t = yices_new_uninterpreted_term(range_tau)
                        yices_set_term_name(t, term.symbol)
                    }
                    else {
                        let domain_taus = [type_t](count:nodes.count, repeatedValue:free_tau)
                        let func_tau = yices_function_type(UInt32(nodes.count), domain_taus, range_tau) // (tau,...,tau) -> range_tau
                        t = yices_new_uninterpreted_term(func_tau)
                        yices_set_term_name(t, term.symbol)
                    }
                }
                
                if nodes.count > 0 {
                    let args = nodes.map { build_yices_term($0, range_tau:free_tau) }
                    t = yices_application(t, UInt32(args.count), args)
                }
                
                return t
            }
            
        }
        
    }
}
