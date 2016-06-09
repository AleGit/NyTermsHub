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
    // var activeClauseIndices = Set<Int>()
    var inactiveClauseIndices = Set<Int>()
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
        
//        repository += clauses.enumerate().map {
//            ($1 ** $0, // make clauses variable distinct by appending clause index
//                -1, // no literal is semantically selected so far
//                Yices.clause($1) // construct yices clause
//            )
//        }
        repository += clauses2entries(clauses, offset:repository.count)
    }
    
    private func clauses2entries<S:SequenceType where S.Generator.Element == N>(clauses:S, offset:Int) -> [Entry] {
        let entries : [Entry] = clauses.enumerate().map {
            ($1 ** ($0+offset), // make clauses variable distinct by appending clause index
                -1, // no literal is semantically selected so far
                Yices.clause($1) // construct yices clause
            )
        }
        Nylog.info("\(entries.count) entries constructed.")
        return entries
        
    }
    
    func append<S:SequenceType where S.Generator.Element == N> (clauses:S) {
        
        repository += clauses2entries(clauses, offset: repository.count)
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
        
        // at this point we do not know which literal will be selected
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
        
        // no literal was selected or the literal does not hold anymore
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
                inactiveClauseIndices.insert(clauseIndex)
            }
        }
        
        return yices_check_context(ctx,nil)
    }
    
    
    
    
    
    
    
    
    func selectclause() -> Int? {
        // the simplest implementation
        // return inactiveClauseIndices.sort().first
        
        // first try to select a inactive unit clause, otherwise try to select a inactive clause
        return unitClauseIndices.intersect(inactiveClauseIndices).first ?? inactiveClauseIndices.first
    }
    
    private func clauseappend(clause:N) -> Int?{
        Nylog.trace("\(#function)(\(clause))")
        
        
        
        let tuple = Yices.clause(clause)
        let subsumers = searchPotentialSubsumersLineary(tuple.yicesLiterals)
        
        guard subsumers.count == 0 else {
            Nylog.info("Not so new clause ignored.")
            Nylog.trace("'\(clause)' ignored.")
            return nil
        }
        
        let newClauseIndex = repository.count
        Nylog.info("NEW CLAUSE # \(newClauseIndex) added.")

        
        let addClause = clause.normalize(newClauseIndex)
        repository.append((addClause,-1,tuple))
        Nylog.trace("'\(addClause)' added.")
        
        return newClauseIndex
    }
    
    func activate(clauseIndex:Int) -> Set<Int> {
        
        var newClauseIndices = Set<Int>()
        
        defer {
            self.inactiveClauseIndices.remove(clauseIndex)
            Nylog.info("Clause # \(clauseIndex) activated.") // :\(entry.0)
            
            indicateClause(clauseIndex)
            // self.activeClauseIndices.insert(clauseIndex)
        }
        
        let entry = repository[clauseIndex]
        
        guard let literal = entry.0.nodes?[entry.literalIndex],
            let candidates = candidateComplementaries(self.literalsTrie, term: literal) else {
                return newClauseIndices
        }
        
        for candidateIndex in candidates {
            let candidateEntry = repository[candidateIndex]
            guard
                let candidateLiteral = candidateEntry.0.nodes?[candidateEntry.literalIndex],
                let unifier = literal ~?= candidateLiteral
                // where !unifier.isRenaming
                else {
                    continue
            }
            
            Nylog.trace("unifier = \(unifier)")
            
            for newClause in [ entry.0 * unifier, candidateEntry.0 * unifier] {
                guard let newIndex = clauseappend(newClause) else { continue }
                newClauseIndices.insert(newIndex)
            }
        }
        
        return newClauseIndices
        
    }
    
    func deactivate(clauseIndex:Int) {
        // self.activeClauseIndices.remove(clauseIndex)
        self.inactiveClauseIndices.insert(clauseIndex)
        
    }
    
    
    func run(timeout:CFTimeInterval = 1.0) -> (smt_status_t,Bool, CFTimeInterval) {
        
        self.endTime = self.startTime + timeout
        guard !self.expired else { return (STATUS_INTERRUPTED,true,self.runtime) }
        
        var (status,_) = Nylog.measure("Preprocess \(repository.count) clauses.", f:self.preprocess)
        var expired = self.expired
        var count = 0
        
        var selectable = true
        
        while !expired && status == STATUS_SAT {
            let mdl = yices_get_model(self.ctx,1)
            
            defer {
                // update status
                (status,_) = Nylog.measure("yices_check_context.") { yices_check_context(self.ctx,nil) }
                expired = self.expired
                count = repository.count
                
                // release model
                yices_free_model(mdl)
            }
            
            if selectable {
                Nylog.measure("(Re)select literals from \(repository.count) clauses.") {
                    for clauseIndex in 0..<self.repository.count {
                        self.yicesreselect(clauseIndex, mdl:mdl)
                    }
                }
                // selectable = false
            }
            
            
            // get inactive clause and activate it
            
            guard let inactiveClauseIndex = selectclause() else {
                assert(inactiveClauseIndices.count==0)
                break;
            }
            
            Nylog.measure("Activate(\(inactiveClauseIndex))" )            {
                
                for newClauseIndex in self.activate(inactiveClauseIndex) {
                    self.yicesassert(newClauseIndex)
                    self.inactiveClauseIndices.insert(newClauseIndex)
                    selectable = true
                }
                
                //            if count == repository.count {
                //                break // nothing was added
                //            }
            }
        }
        
        Nylog.info("EXIT \(#function)(\(timeout)) with status=\(status) expired=\(expired) \(self.runtime.prettyTimeIntervalDescription)")
        
        return (status,expired,self.runtime)
    }
}

extension MingyProver {
    private func indicateClause(clauseIndex:Int, literalIndex:Int) {
        Nylog.trace("\(#function)(\(clauseIndex),\(literalIndex))")
        
        guard literalIndex >= 0 else { return }
        
        guard let literal = repository[clauseIndex].0.nodes?[literalIndex] else {
            Nylog.error("\(clauseIndex).\(literalIndex) selected literal does not exist")
            return
        }
        
        Nylog.trace("* literal=\(literal)")
        
        for path in literal.paths {
            Nylog.trace("+ path:\(path) clauseIndex:\(clauseIndex)")
            literalsTrie.insert(path, value: clauseIndex)
        }
    }
    
    private func deindicateClause(clauseIndex:Int, literalIndex:Int) {
        Nylog.trace("\(#function)(\(clauseIndex),\(literalIndex))")
        
        // if a clause is not in the index then the clause is not active.
        deactivate(clauseIndex)
        
        guard literalIndex >= 0 else { return }
        
        for path in repository[clauseIndex].0.nodes![literalIndex].paths {
            Nylog.trace("- path:\(path) clauseIndex:\(clauseIndex)")
            literalsTrie.delete(path, value: clauseIndex)
        }
        
        
    }
    
    func indicateClause(clauseIndex:Int) {
        Nylog.trace("\(#function) \(#file)\(#line)")
        indicateClause(clauseIndex, literalIndex:repository[clauseIndex].literalIndex)
        
        // when a clause is in the index it can be active or inactive.
    }
    
    func complementaryCandidateIndices(clauseIndex:Int) -> Set<Int>? {
        Nylog.trace("\(#function) \(#file)\(#line)")
        
        let entry = repository[clauseIndex]
        
        guard let literal = entry.0.nodes?[entry.literalIndex] else {
            Nylog.trace("clause#\(clauseIndex):\(entry)")
            return nil
        }
        
        let candidates = candidateComplementaries(literalsTrie, term:literal)
        
        Nylog.trace("??? \(#function)(\(clauseIndex) \(entry.0) \(literal) \(candidates)")
        
        return candidates
        
    }
    
    
    
}

// MARK: literal clause mapping extension
extension MingyProver {
    
    /// Variable-renamed sets of literals are variants of each other.
    func searchPotentialVariantsLinearly(literals:Set<term_t>) -> [Int] {
        let matches = repository.enumerate().filter {
            // activeClauseIndices.contains($0.index) &&
            $0.element.yices.yicesLiterals == literals
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
            // activeClauseIndices.contains($0.index) &&
            $0.element.yices.yicesLiterals.isSubsetOf(literals)
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
