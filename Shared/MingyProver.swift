//
//  MingyProver.swift
//  NyTerms
//
//  Created by Alexander Maringele on 04.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation



class MingyProver<T:Node> : YicesProver {
    
    private let ctx : COpaquePointer
    let free_tau = yices_int_type()
    let bool_tau = yices_bool_type()
    let 🚧 : term_t
    
    private let literalsTrie = TrieClass<SymHop,Int>()
    private let clausesTrie = TrieClass<SymHop,Int>()
    
    private var repository = [(T, literalIndex:Int?, yices:(clause:term_t,literals:[term_t]))]()
    
    private lazy var startTime : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    var runtime : CFTimeInterval {
        return CFAbsoluteTimeGetCurrent() - startTime
    }
    
    init<S:SequenceType where S.Generator.Element == T> (clauses:S) {
        // Create yices context. yices_init() must have been called allready.
        self.ctx = yices_new_context(nil)
        
        self.🚧 = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(self.🚧, "⊥")
        
        self.repository += clauses.map {
            ($0, nil, $0.yicesClause(self))
        }
    }
    
    deinit {
        // Destroy yices context. `yices_exit()` should be called eventually.
        yices_free_context(ctx)
    }
}

extension MingyProver {
    
    func run(maxRuntime:CFTimeInterval = 1) -> smt_status {
        initialYicesAssert()
        
        while runtime < maxRuntime && yices_check_context(ctx,nil) == STATUS_SAT {
                // derive()
        }
        
        return yices_check_context(ctx,nil)
    }
    
}

extension MingyProver {
    func initialYicesAssert() {
        let yicesClauses = self.repository.map {
            $0.yices.clause
        }
        yices_assert_formulas(self.ctx, UInt32(yicesClauses.count), yicesClauses)
    }
}
