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
    
    private let literalsTrie = TrieClass<SymHop,Int>()
    private let clausesTrie = TrieClass<SymHop,Int>()
    
    private var repository = [(N, literalIndex:Int?, yices:(clause:term_t,literals:[term_t]))]()
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
    
    private func selectLiterals() {
        let mdl = yices_get_model(ctx, 1); // create model
        defer { yices_free_model(mdl) } // destroy model at end of function
        
        let holds = { (c,t) in c == Int(1) || yices_formula_true_in_model(mdl, t) == 1 }
        
        for (clauseIndex,var clauseTriple) in self.repository.enumerate() {
            
            if let literalIndex = clauseTriple.literalIndex {
                guard
                    !holds(clauseTriple.yices.literals.count, clauseTriple.yices.literals[literalIndex])
                    else {
                        // selected yices literal still holds in model
                        continue
                }
            }
            
            for (literalIndex,yicesLiteral) in clauseTriple.yices.literals.enumerate() {
                guard literalIndex != clauseTriple.literalIndex else { continue }
                if holds(clauseTriple.yices.literals.count, yicesLiteral) {
                    clauseTriple.literalIndex = literalIndex
                    self.repository[clauseIndex] = clauseTriple
                    
                    print("\(clauseIndex).\(literalIndex) ",
                        "\tl:'\(clauseTriple.0.nodes![literalIndex])'",
                        "\tc:'\(clauseTriple.0)'")
                    
                    self.unprocessedClauseLiteralSet.insert(clauseIndex)
                    
                    continue
                }
            }
            
        }
    }
}
