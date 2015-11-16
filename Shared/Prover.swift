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
    
    /// false or bottom in tptp syntax
    private let bottom = N(connective:"|",nodes:[N]())
    
    private var indexOfFirstUnassertedClause = 0
    
    /// a collection of symbols and their semantics
    private lazy var symbols : [Symbol:SymbolQuadruple] = [Symbol:SymbolQuadruple]()
    
    /// a pointer to a yices context
    private let ctx : COpaquePointer
    
    /// semantics of first order logic is defined over a freely choosable carrier
    /// - the input types of functions are determined by the carrier
    /// - the input types of predicates are determined by the carrier
    /// - the output type of (constant) functions is determined by the carrier
    private let free_tau = yices_int_type()
    
    /// We handle predicates as characteristic functions
    /// - the input types of connectives are Boolean
    /// - the output type of propositions is Boolean
    /// - the output type of predicates is Boolean
    /// - the output type of connectives is Boolean
    private let bool_tau = yices_bool_type()
    
    /// We substitute all variables with the same fresh constant.
    private let 🚧 : term_t
    
    /// We assign a list of clauses and a list of predefined symbols to our prover
    /// Goal: prove that the clauses are unsatisfiable.
    public init(clauses:[N], predefined symbols:[Symbol:SymbolQuadruple]) {
        
        // create a yices context with default configuration
        self.ctx = yices_new_context(nil)
        
        self.🚧 = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(self.🚧, "⊥")
        
        var idx = 0 // append an index to all variables to make them distinct between clauses
        // a(x)|c(x), a(x)|b(x,y) -> a(x1)|c(x1), a(x2)|b(x2,y2)
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
        var round = 0
        while yices_check_context(ctx, nil) == STATUS_SAT {
            let mdl = yices_get_model(ctx, 1);
            defer { yices_free_model(mdl) }
            
            // calculate first holding of selected literals
            let selectedLiterals = clauses.map {
                (tptpClause,yiClause) -> N in
                
                guard let nodes = tptpClause.nodes else {
                    assert(false,"there must no be model with an empty clause")
                    return bottom    // false
                }
                
                switch nodes.count {
                case 0:
                    assert(false,"there must no be model with an empty clause")
                    return bottom
                case 1:
                    assert(1 == yices_formula_true_in_model(mdl, yiClause))
                    return nodes.first!
                case let tcount:
                    assert(Int(yices_term_num_children(yiClause)) == tcount)
                    for idx in 0..<tcount {
                        let child = yices_term_child(yiClause, Int32(idx))
                        if yices_formula_true_in_model(mdl, child) == 1 {
                            return nodes[idx]
                        }
                    }
                }
                
                // at this point no literal was found that holds in the model
                assert(false,"there must no be model with a clause without a literal that holds in the model")
                return bottom
            }
            
            print("\(selectedLiterals.count) literals selected")
            
            var newClauses = [N]()
            
            for i in 0..<(selectedLiterals.count-1) {
                if i%100 == 0 { print(i) }
                for j in (i+1)..<selectedLiterals.count {
                    let a = selectedLiterals[i]
                    let b = selectedLiterals[j]
                    
                    if let unifier = a ~?= b {
                        
                        let na = clauses[i].0 * unifier
                        let nb = clauses[j].0 * unifier
                        
                        // print(na,nb)
                        
                        newClauses.append(na)
                        newClauses.append(nb)
                    }
                }
            }
            
            print("round",round++, "# new clauses",newClauses.count)
            
            guard newClauses.count > 0 else { return }
            
            for tClause in newClauses {
                
                clauses.append((tClause, build_yices_term(tClause, range_tau: bool_tau)))
                
            }
            
            assertClauses()
            
            
            
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

