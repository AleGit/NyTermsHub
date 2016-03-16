//
//  MingyProver.swift
//  NyTerms
//
//  Created by Alexander Maringele on 04.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation


final class MingyProver<N:Node where N.Symbol == String> : YicesProver {
    
    private let ctx : COpaquePointer
    let free_tau = yices_int_type()
    let bool_tau = yices_bool_type()
    let 🚧 : term_t
    
    private var literalsTrie = TrieClass<SymHop<String>,Int>()
    private var clausesTrie = TrieClass<SymHop<String>,Int>()
    
    typealias ClauseTriple = (N, literalIndex:Int?, yices:(clause:term_t,literals:[term_t]))
    
    private var repository = [ClauseTriple]()
    private var unprocessedClauseLiteralSet = Set<Int>()
    
    private lazy var startTime : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    var runtime : CFTimeInterval {
        return CFAbsoluteTimeGetCurrent() - startTime
    }
    
    init<S:SequenceType where S.Generator.Element == N> (clauses:S) {
        // Create yices context. `yices_init()` must have been called allready.
        self.ctx = yices_new_context(nil)
        
        self.🚧 = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(self.🚧, "⊥")
        
        self.repository += clauses.map {
            ($0, nil, self.clause($0))
        }
    }
    
    deinit {
        yices_free_context(self.ctx)
        // Destroy yices context. `yices_exit()` should be called eventually.
    }
}

extension MingyProver {
    func process() {
        
        print(self.unprocessedClauseLiteralSet)
        print(self.literalsTrie)
        print("")
        print(self.clausesTrie)
        
    }
    
    func run(maxRuntime:CFTimeInterval = 1) -> smt_status {
        while self.runtime < maxRuntime && assertClauses() != STATUS_UNSAT {
            selectLiterals()
            process()
            break
        }
        
        
        return yices_check_context(ctx,nil)
    }
}

extension MingyProver {
    /// assert all formulas (clauses) from repository
    private func assertClauses() -> smt_status {
        let unassertedYicesClauses = self.repository.filter { $0.literalIndex == nil }.map {
            $0.yices.clause
        }
        
        yices_assert_formulas(self.ctx, UInt32(unassertedYicesClauses.count), unassertedYicesClauses)
        
        let status =  yices_check_context(ctx,nil)
        return status
    }

    private func removeLiteralClauseIndex(clause:N,clauseIndex:Int,literalIndex:Int?) {
        guard let index = literalIndex else { return } // nothing to do
        
        guard let literals = clause.nodes
            where literals.count > literalIndex else {
                assert(false,"\(clauseIndex).\(literalIndex) clause \(clause) has no or not enough literals.")
                return
        }
        
        for path in literals[index].symHopPaths {
            let val = self.literalsTrie.delete(path, value:clauseIndex)
            assert(val == clauseIndex,
                "\(clauseIndex).\(literalIndex) clause was not previously stored at path '\(path)'. \(clause)")
        }
    }
    
    private func insertLiteralClauseIndex(clause:N, clauseIndex:Int, literalIndex:Int) {
        guard let literals = clause.nodes
            where literals.count > literalIndex else {
            assert(false,"\(clauseIndex).\(literalIndex) clause \(clause) has no or not enough literals.")
            return
        }
        for path in literals[literalIndex].symHopPaths {
            self.literalsTrie.insert(path, value:clauseIndex)
            
            assert(self.literalsTrie.retrieve(path)?.contains(clauseIndex) ?? false,
                "\(clauseIndex).\(literalIndex) clause was not successfully stored at path '\(path)'. \(clause)")
        }
        
    }
    
    private func selectLiterals() {
        let mdl = yices_get_model(ctx, 1); // build model and keep substitutions
        assert(mdl != nil, "no model is available.")
        defer { yices_free_model(mdl) } // release model at end of function
        
        let entailed = { yices_formula_true_in_model(mdl, $0) == 1 }
        
        for (clauseIndex, clauseTriple) in self.repository.enumerate() {
            let (clause,oldLiteralIndex,yices) = clauseTriple
            
            assert(entailed(yices.clause), "\(clauseIndex) \t\(clause) instance \(String(term:yices.clause)) does not hold in model.")
            
            if let literalIndex = oldLiteralIndex where entailed(yices.literals[literalIndex]) {
                continue // the previously selected literal still holds in the model
            }
            
            guard let literalIndex = selectLiteral( yices.literals,
                selectable: entailed, ignorable:  { $0 == oldLiteralIndex } )
            else {
                assert(false,"no literal holds in model.")
                return
            }
            
            if oldLiteralIndex != literalIndex {
                // selected literal index has changed
                removeLiteralClauseIndex(clause, clauseIndex: clauseIndex, literalIndex: oldLiteralIndex)
                insertLiteralClauseIndex(clause, clauseIndex: clauseIndex, literalIndex: literalIndex)
                self.unprocessedClauseLiteralSet.insert(clauseIndex)
                self.repository[clauseIndex].literalIndex = literalIndex
            }
        }
    }
}
