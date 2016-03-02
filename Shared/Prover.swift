//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

protocol Prover {
    typealias N : Node
    
    var symbols : [Symbol:SymbolQuadruple] { get set }
    
    init(clauses:[N], predefined symbols:[Symbol:SymbolQuadruple])
}

class TrieProver<N:Node> : Prover {
    /// A list of first order clauses.
    /// These clauses are implicit universally quantified and variable distinct.
    ///
    ///     a(x)|c(x), a(x)|b(x,y)
    ///         ≣
    ///     (∀x a(x) ∨ c(x)) ∧ (∀x,∀y a(x) ∨ b(x,y))
    ///         ≣
    ///     ∀x1,∀x2,∀y2 (a(x1) ∨ c(x1)) ∧ (a(x2) ∨ b(x2,x2))
    private var clauses = [(N,(yicesClause:term_t,yicesLiterals: [term_t]))]() // tptp clause, yices clause, yices literals
    private var selects = [Int]()
    private var literalsTrie = TrieClass<SymHop,Int>()
    private var clausesTrie = TrieClass<SymHop,Int>()
    
    /// false or bottom in tptp cnf syntax (empty disjunction)
    private let bottom = N(connective:"|",nodes:[N]())
    
    private var indexOfFirstUnassertedClause = 0
    
    /// a collection of symbols and their semantics
    var symbols : [Symbol:SymbolQuadruple]
    
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
    required init(clauses:[N], predefined symbols:[Symbol:SymbolQuadruple]) {
        
        // create a yices context with default configuration
        self.ctx = yices_new_context(nil)
        
        // create global fresh constant
        self.🚧 = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(self.🚧, "⊥")
        
        self.symbols = symbols
        
//        var idx = 0 // append an index to all variables to make them distinct between clauses
//        // a(x)|c(x), a(x)|b(x,y) -> a(x1)|c(x1), a(x2)|b(x2,y2)
//        self.clauses = clauses.map { ($0 ** idx++, buildYicesClause($0)) }
        
        for (clauseIndex, clause) in clauses.enumerate() {
            self.clauses.append((clause ** clauseIndex, buildYicesClause(clause)))
            
            for path in clause.symHopPaths {
                self.clausesTrie.insert(path, value:clauseIndex)
            }
        }
        
        assertClauses()
    }
    
    
    
    /// we must not forget to free the yices context
    deinit {
        yices_free_context(ctx)
    }
}

extension TrieProver {
    convenience init(clauses:[N]) {
        self.init(clauses:clauses, predefined: Symbols.defaultSymbols)
    }
    
    var status : smt_status {
        return yices_check_context(ctx, nil)
    }
    
    func run(maxRounds:Int) -> Int {
        var round = 0
        
        while round < maxRounds {
            let roundStart = CFAbsoluteTimeGetCurrent()
            round += 1
            
            let (context_status, check_time) = measure {
                yices_check_context(self.ctx, nil)
            }
            
            print("round #",round,":","status","=",context_status, check_time.timeIntervalDescriptionMarkedWithUnits)
            
            guard context_status == STATUS_SAT else {
                return round
            }
            
            let start = CFAbsoluteTimeGetCurrent()
            let processed = selects.count
            
            let mdl = yices_get_model(ctx, 1);
            defer { yices_free_model(mdl) }
            
            oldclauses: // check if previously selected literals still hold
                for (clauseIndex, clause) in clauses[0..<selects.count].enumerate() {
                    let selectedLiteralIndex = selects[clauseIndex]
                    let selectedYicesLiteral = clause.1.yicesLiterals[selectedLiteralIndex]
                    
                    guard yices_formula_true_in_model(mdl, selectedYicesLiteral) == 0 else {
                        // selected yicesliteral still holds in yices model
                        continue oldclauses
                    }
                    
                    // selected yicesliteral does not hold in yices model
                    // remove literal from trie
                    for path in clause.0.nodes![selectedLiteralIndex].symHopPaths {
                        literalsTrie.delete(path, value: clauseIndex)
                    }
                    
                    selects[clauseIndex] = -selectedLiteralIndex // mark as changed
            }
            
            var newClauses = [N]()
            newclauses:
                for (clauseIndex, clause) in clauses.enumerate() {
                    var selectedLiteralIndex = clauseIndex < selects.count ? selects[clauseIndex] : Int.min
                    if selectedLiteralIndex < 0 {
                        // a unprocessed clause or a clause with changed the selected literal
                        let yicesLiterals = clause.1.yicesLiterals
                        
                        literals: // search for holding literals
                            for (index,yicesLiteral) in yicesLiterals.enumerate() {
                                guard index != selectedLiteralIndex && yices_formula_true_in_model(mdl, yicesLiteral) == 1 else {
                                    // the literal does not hold
                                    continue literals
                                }
                                
                                // select literal
                                selectedLiteralIndex = index
                                
                                if clauseIndex < selects.count {
                                    selects[clauseIndex] = selectedLiteralIndex
                                }
                                else {
                                    assert(clauseIndex == selects.count)
                                    selects.append(selectedLiteralIndex)
                                }
                                
                                let selectedLiteral = clause.0.nodes![selectedLiteralIndex]
                                
                                // search for complementary literals
                                
                                if let candidateLiteralIndices = candidateComplementaries(literalsTrie, term:selectedLiteral) {
                                    for candidateLiteralIndex in candidateLiteralIndices {
                                        let candidateClause = clauses[candidateLiteralIndex].0
                                        let candidateLiteral = candidateClause.nodes![selects[candidateLiteralIndex]]
                                        guard let mgu = selectedLiteral ~?= candidateLiteral
                                            else { continue }
                                        
                                        instances:
                                        for clause in [clauses[clauseIndex].0, clauses[candidateLiteralIndex].0] {
                                            let newClause = clause * mgu
                                            let newClauseIndex = self.clauses.count + newClauses.count
                                            
                                            if let variants = candidateVariants(self.clausesTrie, term: newClause)
                                                where variants.count > 0 {
                                                    for variant in variants {
                                                        let variantClause : N
                                                        if variant < clauses.count {
                                                            variantClause = clauses[variant].0
                                                        }
                                                        else {
                                                            let idx = variant - clauses.count
                                                            variantClause = newClauses[idx]

                                                        }
                                                        
                                                        if variantClause.isVariant(newClause) {
                                                            continue instances
                                                        }
                                                        else {
                                                            print("\n",variantClause, "\n",newClause, "are not variants")
                                                        }
                                                    }
                                                    
                                                    
                                            }
                                            
                                            newClauses.append(newClause)
                                            
                                            for path in clause.symHopPaths {
                                                self.clausesTrie.insert(path, value:newClauseIndex)
                                            }
                                        }
                                        
                                        // TODO: configurable
                                        if (newClauses.count % 1000) <= 1
                                            && (CFAbsoluteTimeGetCurrent()-roundStart) > 10.0 {
                                            break newclauses
                                        }
                                    }
                                }
                                
                                
                                
                                // insert literal into trie (term index)
                                for path in selectedLiteral.symHopPaths {
                                    literalsTrie.insert(path, value: clauseIndex)
                                }
                                
                        }
                        
                        
                    }
            }
            
            print("round #", round, ":",newClauses.count, "new clauses in", (CFAbsoluteTimeGetCurrent()-start).timeIntervalDescriptionMarkedWithUnits)
            
            guard newClauses.count > 0 else { return round }
            
            var idx = indexOfFirstUnassertedClause
            
            for tClause in newClauses {
                let pair = buildYicesClause(tClause)
                let newClause = (tClause ** idx++, pair)
                
                clauses.append(newClause)
                
            }
            
            assertClauses()
            
            
            
        }
        
        return round
        
        
    }
}

private extension TrieProver {
    private func assertClauses() {
        let unasserted = clauses[indexOfFirstUnassertedClause..<clauses.count].map { $0.1.0 }
        indexOfFirstUnassertedClause = clauses.count
        yices_assert_formulas(ctx, UInt32(unasserted.count), unasserted)
    }
}

extension TrieProver {
    
    private func createQuadruple(symbol: String, type:SymbolType, arity:Int) -> SymbolQuadruple {
        guard var quadruple = symbols[symbol] else {
            return (type:type, category:SymbolCategory.Functor, notation:SymbolNotation.Prefix, arities: arity...arity)
        }
        
        assert(quadruple.type == type, "type of \(symbol) is \(quadruple.type) instead of \(type)")
        assert(quadruple.category == SymbolCategory.Functor, "category of \(symbol) is \(quadruple.category) instead of \(SymbolCategory.Functor)")
        assert(quadruple.notation == SymbolNotation.Prefix, "notation of \(symbol) is \(quadruple.notation) instead of \(SymbolNotation.Prefix)")
        assert(quadruple.arities.contains(arity), "arities of \(symbol): \(quadruple.arities) does not include \(arity)")
        
        quadruple.arities.insert(arity)
        
        return quadruple
        
        
    }
    
    /// protocol extension Prover.register cannot be invoked in the class?
    func register(predicate symbol:String, arity:Int) -> SymbolQuadruple {
        let quadruple = createQuadruple(symbol, type:SymbolType.Predicate, arity:arity)
        
        self.symbols[symbol] = quadruple
        
        return quadruple
    }
    
    func register(function symbol:String, arity:Int) -> SymbolQuadruple {
        
        let quadruple = createQuadruple(symbol, type:SymbolType.Function, arity:arity)
        
        // self.symbols[symbol] = quadruple // do not register function symbols
        
        return quadruple
    }
    
}

private extension TrieProver {
    
    
    func buildYicesClause<N:Node>(clause:N) -> (yicesClause: term_t, yicesLiterals: [term_t]) {
        guard let literals = clause.nodes else { return (yicesClause: yices_false(), yicesLiterals: [term_t]()) }
        
        let quadruple = self.symbols[clause.symbol] ?? register(predicate: clause.symbol, arity: literals.count)
        
        switch quadruple.type {
            //        case SymbolType.Disjunction where literals.count == 0:
            //            // clause with literals
            //            guard literals.count > 0 else { return (yicesClause: yices_false(), yicesLiterals: [term_t]()) }
            //
        case SymbolType.Disjunction:
            
            var yicesLiterals = literals.map { buildYicesTerm($0, range_tau:bool_tau) }
            let yicesClause = yices_or( UInt32(yicesLiterals.count), &yicesLiterals)
            
            return (yicesClause, yicesLiterals)
            
        case SymbolType.Predicate, SymbolType.Equation, SymbolType.Inequation, SymbolType.Negation:
            // unit clause
            let yicesUnitClause = buildYicesTerm(clause, range_tau:bool_tau)
            
            return (yicesUnitClause, [term_t]())
            
            
        default:
            assertionFailure("\(clause.symbol):\(quadruple) is not the root of a clause.")
            return (yicesClause: yices_false(), yicesLiterals: [term_t]())
        }
    }
    
    
    func buildYicesTerm<N:Node>(term:N, range_tau:type_t) -> term_t {
        
        // map all variables to global distinct constant '⊥'
        guard let nodes = term.nodes else { return 🚧 }
        
        
        let quadruple = self.symbols[term.symbol] ?? (
            range_tau == bool_tau ?
                register(predicate: term.symbol, arity: nodes.count)
                :
                (type:SymbolType.Function, category:SymbolCategory.Functor, notation:SymbolNotation.Prefix, arities: nodes.count...nodes.count)
        )
        
        switch quadruple.type {
        case .Negation:
            assert(nodes.count == 1)
            return yices_not( buildYicesTerm(nodes.first!, range_tau:bool_tau))
            
        case .Disjunction:
            var args = nodes.map { buildYicesTerm($0, range_tau: bool_tau) }
            return yices_or( UInt32(nodes.count), &args)
            
        case .Conjunction:
            var args = nodes.map { buildYicesTerm($0, range_tau: bool_tau) }
            return yices_and( UInt32(nodes.count), &args)
            
        case .Inequation:
            assert(nodes.count == 2)
            let args = nodes.map { buildYicesTerm($0, range_tau: free_tau) }
            return yices_neq(args.first!,args.last!)
            
        case .Equation:
            assert(nodes.count == 2)
            let args = nodes.map { buildYicesTerm($0, range_tau: free_tau) }
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
                
                let args = nodes.map { buildYicesTerm($0, range_tau:free_tau) }
                let appl = yices_application(t, UInt32(args.count), args)
                return appl // : range
            }
            else {
                return t // : range
            }
        }
        
    }
}




