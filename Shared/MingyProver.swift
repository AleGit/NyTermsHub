//
//  MingyProver.swift
//  NyTerms
//
//  Created by Alexander Maringele on 04.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

private class SubtermInfo : UnitArrayPair {
    let unit:Int
    let array:[Int]
    
    var clauseIndex : Int { return unit }
    var subTermPosition : [Int] { return array }
    
    init(clauseIndex:Int,subTermPosition:[Int]) {
        self.unit = clauseIndex
        self.array = subTermPosition
    }
}
/// - Create a prover with initial set of clauses. T
/// The repository will be filled, but no clauses are active at this point.
/// - Start the prover with run(timeout). It will activate one clauses one by one.
final class MingyProver<N:Node where N.Symbol == String> {
    
    private let ctx : COpaquePointer
    
    // typealias ClauseTriple = (N, literalIndex:Int?, yices:(clause:term_t,literals:[term_t]))
    typealias Entry = (N, literalIndex:Int, yices:Yices.Tuple)
    
    /// stores all (!) clauses and their variable free yices counterparts
    private var repository = [Entry]()
    
    /// keeps track of acitve, i.e. completly processed clauses
    var activeClauseIndices = Set<Int>()
    var unitClauseIndices = Set<Int>()
    
    /// stores paths of (semantically) selected literals to active clause indices
    private var literalsTrie = TrieClass<SymHop<String>,Int>()
    
    /// stores paths of subterms of (semantically) selected literals to active clause indices
    private var subtermsTrie = TrieClass<SymHop<String>,SubtermInfo>()
    
    // clause Index
    // private var clauseIndex = [Int : Set<Int>]()
    
    
    
    // private var repository = [ClauseTriple]()
    // private var unprocessedClauseLiteralSet = Set<Int>()
    
    private lazy var startTime : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    private var endTime : CFAbsoluteTime = 0.0
    
    var expired : Bool { return endTime < CFAbsoluteTimeGetCurrent() }
    var runtime : CFTimeInterval { return CFAbsoluteTimeGetCurrent() - startTime }
    
    init<S:SequenceType where S.Generator.Element == N> (clauses:S) {
        // Create yices context. `yices_init()` must have been called allready.
        
        self.ctx = yices_new_context(nil)
        
        repository += clauses.enumerate().map {
            ($1 ** $0, // make clauses variable distinct by appending clause index
                -1, // no literal is semantically selected so far
                Yices.clause($1) // construct yices clause
            )
        }
    }
    
    deinit {
        yices_free_context(self.ctx)
        // Destroy yices context. `yices_exit()` should be called eventually.
    }
}

extension MingyProver {
    private func yicesassert(clauseIndex:Int) -> Int? {
        let entry = repository[clauseIndex]
        let code = yices_assert_formula(ctx,entry.yices.yicesClause)
        assert(code >= 0)
        
        if entry.yices.alignedYicesLiterals.count == 1 {
            unitClauseIndices.insert(clauseIndex)
            // it is a unit clause, hence the first (and only) literal is selected            
            return 0
        }
        else if entry.yices.yicesLiterals.count == 1 {
            // the relevant literals are variants of each other : x ≥ y | y ≥ x
            // or the clause is trivially true ~p(x) | p(x)
            
            if let lid = entry.yices.yicesLiterals.first,
                let lidx = entry.yices.alignedYicesLiterals.indexOf(lid) {
                return lidx
            }
        }
        return nil
    }
    
    private func yicesreselect(clauseIndex:Int, mdl:COpaquePointer) {
        let entry = repository[clauseIndex]
        let literalIndex = entry.literalIndex
        guard literalIndex < 0
            || yices_formula_true_in_model(mdl, entry.yices.alignedYicesLiterals[literalIndex]) != 1
            else {
            // literalIndex >= 0 && yices_formula_true_in_model(mdl, lid) == 1 (true)
            return
        }
        
        deindicateClause(clauseIndex, literalIndex:literalIndex)
        
        for lid in entry.yices.yicesLiterals {
            guard yices_formula_true_in_model(mdl, lid) == 0 else {
                repository[clauseIndex].literalIndex = entry.yices.alignedYicesLiterals.indexOf(lid) ?? -1
                
                assert(repository[clauseIndex].literalIndex != -1)
                return
            }
        }
        
        assert(false)
        
    }
    
    func preprocess() -> smt_status_t {
        for clauseIndex in 0..<repository.count {
            if let lidx = yicesassert(clauseIndex) {
                repository[clauseIndex].literalIndex = lidx
                indicateClause(clauseIndex, literalIndex: lidx)
            }
        }
        
        return yices_check_context(ctx,nil)
    }
    
    
    func run(timeout:CFTimeInterval) -> (smt_status_t,Bool, CFTimeInterval) {
        self.endTime = self.startTime + timeout
        guard !self.expired else { return (STATUS_INTERRUPTED,true,self.runtime) }
        
        var status = preprocess()
        var expired = self.expired
        
        while expired && status == STATUS_SAT {
            let mdl = yices_get_model(self.ctx,1)
            defer { yices_free_model(mdl) }
            
            
            
            for clauseIndex in 0..<repository.count {
                yicesreselect(clauseIndex, mdl:mdl)
            }
            
            status = yices_check_context(ctx,nil)
            expired = self.expired
        }
        

        
        
        
        return (status,expired,self.runtime)
    }
}

extension MingyProver {
    private func indicateClause(clauseIndex:Int, literalIndex:Int) {
        guard literalIndex >= 0 else { return }
        
        for path in repository[clauseIndex].0.nodes![literalIndex].paths {
            literalsTrie.insert(path, value: clauseIndex)
        }
    }
    
    private func deindicateClause(clauseIndex:Int, literalIndex:Int) {
        guard literalIndex >= 0 else { return }
        
        for path in repository[clauseIndex].0.nodes![literalIndex].paths {
            literalsTrie.delete(path, value: clauseIndex)
        }
    }
    
    func indicateClause(clauseIndex:Int) {
        indicateClause(clauseIndex, literalIndex:repository[clauseIndex].literalIndex)
    }
    
    func complementaryCandidateIndices(clauseIndex:Int) -> Set<Int>? {
        let literal = repository[clauseIndex].0
        
        return candidateComplementaries(literalsTrie, term:literal)
        
    }
    
    
    
}

// MARK: literal clause mapping extension
extension MingyProver {
    
    /// Variable-renamed sets of literals are variants of each other.
    func searchPotentialVariantsLinearly(literals:Set<term_t>) -> [Int] {
        let matches = repository.enumerate().filter {
            activeClauseIndices.contains($0.index) && $0.element.yices.yicesLiterals == literals
            }.map { $0.0 }
        return matches
    }
    
    /// A first clause is a variant of a second clause, if there is a renaming such that
    /// the first set of literals is equal to the second set of literals.
    ///
    /// Notes:
    /// - f(X)|f(X)|g(X,Y) is variant of f(Y)|g(Y,Z) in this definition.
    /// - Usually clauses are defined as multi-sets of literals and
    /// f(X)|f(X)|g(X,Y) would not be a variant of f(Y)|g(Y,Z)
    /// - since all variables are substituted with the same constant
    /// this function can return clauses, which are actually not variants:
    ///     - f(X) | g(X,X) is actually not a variant of f(X) | g(X,Z)
    ///     - f(X) | f(Y) | g(X,Y) vs. f(X) | g(X,Y)?
    func searchPotentialVariantsLinearly(clauseIndex:Int) -> [Int] {
        return searchPotentialVariantsLinearly( repository[clauseIndex].yices.yicesLiterals )
    }
    
    /// Each set of literals subsumes its variable-renamed supersets.
    func searchPotentialSubsumersLineary<S:SequenceType where S.Generator.Element == term_t>(literals:S) -> [Int] {
        let matches = repository.enumerate().filter {
            activeClauseIndices.contains($0.index) && $0.element.yices.yicesLiterals.isSubsetOf(literals)
            }.map { $0.0 }
        return matches
    }
    
    /// A clause subsumes a given clause if there is variable-renamed literals are a subset of the given set of literals.
    /// Note: Variants subsume each other.
    /// candidates, which do not subssume:
    /// -
    func searchPotentialSubsumersLineary(clauseIndex:Int) -> [Int] {
        return searchPotentialSubsumersLineary( repository[clauseIndex].yices.yicesLiterals )
    }
}

// MARK: incompleted
extension MingyProver {
    func select(clauseIndex:Int) -> Int {
        return -1
    }
    
    func process(clauseIndex:Int) {
        assert(!activeClauseIndices.contains(clauseIndex))
        
        // check if strengthend clause is allready in index
        
        
        activeClauseIndices.insert(clauseIndex)
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
