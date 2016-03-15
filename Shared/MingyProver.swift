//
//  MingyProver.swift
//  NyTerms
//
//  Created by Alexander Maringele on 04.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation


final class MingyProver<N:Node> : YicesProver {
    
    private let ctx : COpaquePointer
    let free_tau = yices_int_type()
    let bool_tau = yices_bool_type()
    let 🚧 : term_t
    
    private var literalsTrie = TrieClass<SymHop,Int>()
    private var clausesTrie = TrieClass<SymHop,Int>()
    
    typealias ClauseTriple = (N, literalIndex:Int?, yices:(clause:term_t,literals:[term_t]))
    
    private var repository = [ClauseTriple]()
    private var unprocessedClauseLiteralSet = Set<Int>()
    
    private lazy var startTime : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    var runtime : CFTimeInterval {
        return CFAbsoluteTimeGetCurrent() - startTime
    }
    
    init<S:SequenceType where S.Generator.Element == N> (clauses:S) {
        // `yices_init()` must have been called allready.
        // Create yices context.
        self.ctx = yices_new_context(nil)
        
        self.🚧 = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(self.🚧, "⊥")
        
        self.repository += clauses.map {
            ($0, nil, self.clause($0))
        }
    }
    
    deinit {
        yices_free_context(self.ctx)
        // Destroy yices context.
        // `yices_exit()` should be called eventually.
    }
}

extension MingyProver {
    
    func run(maxRuntime:CFTimeInterval = 1) -> smt_status {
        while self.runtime < maxRuntime && assertClauses() != STATUS_UNSAT {
            selectLiterals()
        }
        
        print(self.unprocessedClauseLiteralSet)
        
        return yices_check_context(ctx,nil)
    }
    
}

extension MingyProver {
    private func assertClauses() -> smt_status {
        let unassertedYicesClauses = self.repository.filter { $0.literalIndex == nil }.map {
            $0.yices.clause
        }
        
        yices_assert_formulas(self.ctx, UInt32(unassertedYicesClauses.count), unassertedYicesClauses)
        
        let status =  yices_check_context(ctx,nil)
        return status
    }
    
    private func makeSelectable(mdl:COpaquePointer) -> ((Int,term_t) -> Bool) {
        return {
            (count,term) in count == 1 as Int || // select the only literal of a unit clause
                yices_formula_true_in_model(mdl, term) == 1 // or a literal that is true in the model
        }
    }
    

    private func removeLiteralClauseIndex(clause:N,clauseIndex:Int,literalIndex:Int) {
        guard let literal = clause.nodes?[literalIndex] else {
            assert(false,"impossible")
            return
        }
        for path in literal.symHopPaths {
            let val = self.literalsTrie.delete(path, value:clauseIndex)
            assert(val == clauseIndex,
                "\(clauseIndex).\(literalIndex) clause was not previously stored under path '\(path)'. \(clause)")
        }
    }
    
    private func insertSelectedLiteralClauseIndex(clause:N, clauseIndex:Int, literalIndex:Int) {
        guard let literal = clause.nodes?[literalIndex] else {
            assert(false,"impossible")
            return
        }
        for path in literal.symHopPaths {
            self.literalsTrie.insert(path, value:clauseIndex)
            
            assert(self.literalsTrie.retrieve(path)?.contains(clauseIndex) ?? false,
                "\(clauseIndex).\(literalIndex) clause was not successfully stored under path '\(path)'. \(clause)")
        }
        
    }
    
    private func selectLiteral(clauseTriple:ClauseTriple, selectable:(Int,term_t)->Bool) -> (literalIndex:Int, hasChanged:Bool) {

        let (_,_,yices) = clauseTriple
        
        let literalsCount = yices.literals.count
        
        if let literalIndex = clauseTriple.literalIndex {
            // a literal was selected previously
            let yicesLiteral =  clauseTriple.yices.literals[literalIndex]
            
            guard !selectable(literalsCount, yicesLiteral) else {
                return (literalIndex,false)    // previously selected literal still holds in model
            }
        }
        
        for (literalIndex,yicesLiteral) in clauseTriple.yices.literals.enumerate() {
            guard literalIndex != clauseTriple.literalIndex else {
                continue    // previously selected literal does not hold in model
            }
            
            if selectable(literalsCount, yicesLiteral) {
                
                return (literalIndex,true)
            }
        }
        
        assert(false,"impossible: no literal holds in model")
        
    }
    
    
    private func selectLiterals() {
        let mdl = yices_get_model(ctx, 1); // create model
        defer { yices_free_model(mdl) } // destroy model at end of function
        
        let selectable = makeSelectable(mdl)
        
        for (clauseIndex, clauseTriple) in self.repository.enumerate() {
            let (clause,_,_) = clauseTriple
            
            let (literalIndex,hasChanged) = selectLiteral(clauseTriple, selectable: selectable)
            
            if hasChanged {
                if let oldLiteralIndex = clauseTriple.literalIndex {
                    removeLiteralClauseIndex(clause, clauseIndex: clauseIndex, literalIndex: oldLiteralIndex)
                }
                
                insertSelectedLiteralClauseIndex(clause, clauseIndex: clauseIndex, literalIndex: literalIndex)
                self.unprocessedClauseLiteralSet.insert(clauseIndex)
            }
        }
    }
}
