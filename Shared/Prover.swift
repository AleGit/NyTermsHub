//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation



public final class YiProver<N:Node> {
    /// A list of first order clauses.
    /// These clauses are implicit universally quantified and variable distinct.
    /// 
    ///     a(x)|c(x), a(x)|b(x,y)
    ///         ≣
    ///     (∀x a(x) ∨ c(x)) ∧ (∀x,∀y a(x) ∨ b(x,y))
    ///         ≣
    ///     ∀x1,∀x2,∀y2 (a(x1) ∨ c(x1)) ∧ (a(x2) ∨ b(x2,x2))
    private lazy var clauses : [(N,term_t)] = [(N,term_t)]()
    
    private var indexOfFirstUnassertedClause = 0
    
    /// a collection of symbols and their semantics
    private lazy var symbols : [Symbol:SymbolQuadruple] = [Symbol:SymbolQuadruple]()
    
    /// a pointer to an yices context
    private var ctx : COpaquePointer
    
    /// semantics of first order logic is defined over a freely choosable carrier
    /// - the input types of functions are determined by the carrier
    /// - the input types of predicates are determined by the carrier
    /// - the output type of (constant) functions is determined by the carrier
    private var free_tau = yices_int_type()
    
    /// We handle predicates as characteristic functions
    /// - the input types of connectives are Boolean
    /// - the output type of propositions is Boolean
    /// - the output type of predicates is Boolean
    /// - the output type of connectives is Boolean
    private var bool_tau = yices_bool_type()
    
    /// We substitute all variables with the same fresh constant.
    private var 🚧 : term_t = NULL_TERM
    
    /// We assign a list of (unsatisfiable) clauses
    /// and a list of predefined symbols to our prover
    public init(clauses:[N], predefined symbols:[Symbol:SymbolQuadruple]) {
        // create context
        self.ctx = yices_new_context(nil)
        self.🚧 = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(self.🚧, "⊥")
        
        // assign input
        var idx = 0
        self.clauses = clauses.map { ($0 ** idx++, build_yices_term($0, range_tau: bool_tau)) }
        self.symbols = symbols
        
        assertClauses()
    }
    
    /// we must not forget to free the yices context
    deinit {
        yices_free_context(ctx)
    }
}

public extension YiProver {
    public convenience init(clauses:[N]) {
        self.init(clauses:clauses, predefined: Symbols.defaultSymbols)
    }
    
    public var status : smt_status {
        return yices_check_context(ctx, nil)
    }
    
    public func run() {
        while yices_check_context(ctx, nil) == STATUS_SAT {
            
        }
        
    }
}

private extension YiProver {
    private func assertClauses() {
        let unasserted = clauses[indexOfFirstUnassertedClause..<clauses.count].map { $0.1 }
        indexOfFirstUnassertedClause = clauses.count
        yices_assert_formulas(ctx, UInt32(unasserted.count), unasserted)
    }
}

private extension YiProver {
    func build_yices_term<N:Node>(term:N, range_tau:type_t) -> term_t {
        
        // map all variables to global distinct constant '⊥'
        guard let nodes = term.nodes else { return 🚧 }
        
        // TODO: use symbols and type
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
            // proposition : bool, predicate : (free^n) -> bool,
            // constant : free, or function : (free^n) -> free.
            
            var t = yices_get_term_by_name(term.symbol)
            
            if t == NULL_TERM {
                if nodes.count == 0 {
                    // proposition : bool (range)
                    // or constant : free (range)
                    t = yices_new_uninterpreted_term(range_tau)
                    yices_set_term_name(t, term.symbol)
                }
                else {
                    // predicate    : (free^n) -> bool (range)
                    // or function  : (free^n) -> free (range)
                    let domain_taus = [type_t](count:nodes.count, repeatedValue:free_tau)
                    let func_tau = yices_function_type(UInt32(nodes.count), domain_taus, range_tau)
                    t = yices_new_uninterpreted_term(func_tau)
                    yices_set_term_name(t, term.symbol)
                }
            }
            
            if nodes.count > 0 {
                // application: ((free^n) -> range) . (free^n)
                
                let args = nodes.map { build_yices_term($0, range_tau:free_tau) }
                let appl = yices_application(t, UInt32(args.count), args)
                return appl // : range
            }
            else {
                return t // : range
            }
        }
        
    }
}

