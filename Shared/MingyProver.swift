//
//  MingyProver.swift
//  NyTerms
//
//  Created by Alexander Maringele on 04.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Array where Element : Hashable {
    var hashValue: Int {
        return self.reduce(5381) {
            ($0 << 5) &+ $0 &+ $1.hashValue
        }
    }
}

private class SubtermInfo : Hashable {
    let index:Int
    let position:[Int]
    
    init(index:Int,position:[Int]) {
        self.index = index
        self.position = position
    }
    
    var hashValue: Int {
        return self.index &* position.hashValue
    }
}

private func ==(lhs:SubtermInfo, rhs:SubtermInfo) -> Bool {
    return lhs.index == rhs.index && lhs.position == rhs.position
}

final class MingyProver<N:Node where N.Symbol == String> {
    
    private let ctx : COpaquePointer
    let free_tau = Yices.int_tau
    let bool_tau = Yices.bool_tau
    let 🚧 : term_t
    
    typealias Entry = (N, literalIndex:Int, yices:Yices.Tuple)
    
    private var repository = [Entry]()
    // private var literalClauseMapping = [term_t: Set<Int>]()
    
    // literalsIndex
    private var literalsTrie = TrieClass<SymHop<String>,Int>()
    
    private var subtermsTrie = TrieClass<SymHop<String>,SubtermInfo>()
    
    // clause Index
    private var clauseIndex = [Int : Set<Int>]()
    
    typealias ClauseTriple = (N, literalIndex:Int?, yices:(clause:term_t,literals:[term_t]))
    
    // private var repository = [ClauseTriple]()
    // private var unprocessedClauseLiteralSet = Set<Int>()
    
    private lazy var startTime : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    var runtime : CFTimeInterval { return CFAbsoluteTimeGetCurrent() - startTime }
    
    init<S:SequenceType where S.Generator.Element == N> (clauses:S) {
        // Create yices context. `yices_init()` must have been called allready.
        
        self.ctx = yices_new_context(nil)
        
        self.🚧 = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(self.🚧, "⊥")
        
        repository += clauses.enumerate().map {
            ($1 ** $0, -1, Yices.clause($1))
            
            // clause ** index : append clause index to variable names to make clauses variable distinct
        }
    }
    
    var processedClauseIndices = Set<Int>()
    
    
    deinit {
        yices_free_context(self.ctx)
        // Destroy yices context. `yices_exit()` should be called eventually.
    }
}

// MARK: literal clause mapping extension
extension MingyProver {
    
//    func insert(literal:term_t, clause:Int) {
//        if literalClauseMapping[literal] == nil {
//            literalClauseMapping[literal] = Set(arrayLiteral:clause)
//        }
//        else {
//            literalClauseMapping[literal]?.insert(clause)
//        }
//    }
//    
//    func insert<S:SequenceType where S.Generator.Element == term_t>(literals:S, clause:Int) {
//        for literal in literals {
//            insert(literal, clause: clause)
//        }
//    }
//    
//    func remove(literal:term_t, clause:Int) {
//        literalClauseMapping[literal]?.remove(clause)
//    }
//    
//    func remove<S:SequenceType where S.Generator.Element == term_t>(literals:S, clause:Int) {
//        for literal in literals {
//            remove(literal, clause:clause)
//        }
//    }
    
    func searchVariantsLinearly(literals:Set<term_t>) -> [Int] {
        let matches = repository.enumerate().filter {
            processedClauseIndices.contains($0.index) && $0.element.yices.yicesLiterals == literals
            }.map { $0.0 }
        return matches
    }
    
    func searchVariantsLinearly(clauseIndex:Int) -> [Int] {
        return searchVariantsLinearly( repository[clauseIndex].yices.yicesLiterals )
        
    }
    
    func searchSubsumptionerLinearly<S:SequenceType where S.Generator.Element == term_t>(literals:S) -> [Int] {
        let matches = repository.enumerate().filter {
            processedClauseIndices.contains($0.index) && $0.element.yices.yicesLiterals.isSubsetOf(literals)
            }.map { $0.0 }
        return matches
        
    }
}

// MARK: incompleted
extension MingyProver {
    func select(clauseIndex:Int) -> Int {
        return -1
    }
    
    func searchSubsumptionCandidates(clauseIndex:Int) {
        
    }
    
    func process(clauseIndex:Int) {
        assert(!processedClauseIndices.contains(clauseIndex))
        
        // check if strengthend clause is allready in index
        
        
        processedClauseIndices.insert(clauseIndex)
    }
    
}

//
//extension MingyProver {
//    func process() {
//
//        print(self.unprocessedClauseLiteralSet)
//        print(self.literalsTrie)
//        print("")
//
//    }
//
//    func run(maxRuntime:CFTimeInterval = 1) -> smt_status {
//        while self.runtime < maxRuntime && assertClauses() != STATUS_UNSAT {
//            selectLiterals()
//            process()
//            break
//        }
//
//
//        return yices_check_context(ctx,nil)
//    }
//}
//
//extension MingyProver {
//    /// assert all formulas (clauses) from repository
//    private func assertClauses() -> smt_status {
//        let unassertedYicesClauses = self.repository.filter { $0.literalIndex == nil }.map {
//            $0.yices.clause
//        }
//
//        yices_assert_formulas(self.ctx, UInt32(unassertedYicesClauses.count), unassertedYicesClauses)
//
//        let status =  yices_check_context(ctx,nil)
//        return status
//    }
//
//    private func removeLiteralClauseIndex(clause:N,clauseIndex:Int,literalIndex:Int?) {
//        guard let index = literalIndex else { return } // nothing to do
//
//        guard let literals = clause.nodes
//            where literals.count > literalIndex else {
//                assert(false,"\(clauseIndex).\(literalIndex) clause \(clause) has no or not enough literals.")
//                return
//        }
//
//        for path in literals[index].paths {
//            let val = self.literalsTrie.delete(path, value:clauseIndex)
//            assert(val == clauseIndex,
//                "\(clauseIndex).\(literalIndex) clause was not previously stored at path '\(path)'. \(clause)")
//        }
//    }
//
//    private func insertLiteralClauseIndex(clause:N, clauseIndex:Int, literalIndex:Int) {
//        guard let literals = clause.nodes
//            where literals.count > literalIndex else {
//            assert(false,"\(clauseIndex).\(literalIndex) clause \(clause) has no or not enough literals.")
//            return
//        }
//        for path in literals[literalIndex].paths {
//            self.literalsTrie.insert(path, value:clauseIndex)
//
//            assert(self.literalsTrie.retrieve(path)?.contains(clauseIndex) ?? false,
//                "\(clauseIndex).\(literalIndex) clause was not successfully stored at path '\(path)'. \(clause)")
//        }
//
//    }
//
//    private func selectLiterals() {
//        let mdl = yices_get_model(ctx, 1); // build model and keep substitutions
//        assert(mdl != nil, "no model is available.")
//        defer { yices_free_model(mdl) } // release model at end of function
//
//        let entailed = { yices_formula_true_in_model(mdl, $0) == 1 }
//
//        for (clauseIndex, clauseTriple) in self.repository.enumerate() {
//            let (clause,oldLiteralIndex,yices) = clauseTriple
//
//            assert(entailed(yices.clause), "\(clauseIndex) \t\(clause) instance \(String(term:yices.clause)) does not hold in model.")
//
//            if let literalIndex = oldLiteralIndex where entailed(yices.literals[literalIndex]) {
//                continue // the previously selected literal still holds in the model
//            }
//
//            guard let literalIndex = selectLiteral( yices.literals,
//                selectable: entailed, ignorable:  { $0 == oldLiteralIndex } )
//            else {
//                assert(false,"no literal holds in model.")
//                return
//            }
//
//            if oldLiteralIndex != literalIndex {
//                // selected literal index has changed
//                removeLiteralClauseIndex(clause, clauseIndex: clauseIndex, literalIndex: oldLiteralIndex)
//                insertLiteralClauseIndex(clause, clauseIndex: clauseIndex, literalIndex: literalIndex)
//                self.unprocessedClauseLiteralSet.insert(clauseIndex)
//                self.repository[clauseIndex].literalIndex = literalIndex
//            }
//        }
//    }
//}
