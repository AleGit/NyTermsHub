//
//  File.swift
//  NyTerms
//
//  Created by Alexander Maringele on 13.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension TptpNode {
    typealias Tuple = (node:TptpNode,selected:Int,triple:Yices.Triple)
}



struct Demo {
    static func parse(file:TptpPath) -> [TptpNode] {
        let (clauses,parseTime) = measure { TptpNode.roots(file) }
        print("\(clauses.count) clauses parsed in \(parseTime.prettyTimeIntervalDescription) (\(parseTime)).")
        return clauses
    }
    
    static func construct(clauses:[TptpNode], baseIndex : Int = 0) -> [TptpNode.Tuple] {
        let (tptpTuples, clauseTime) = measure {
            clauses.enumerate().map { (node:$1 ** (baseIndex+$0), selected:-1,triple:Yices.clause($1.nodes!)) }
        }
        // print("\(tptpTuples.count) yices clauses constructed in \(clauseTime.prettyTimeIntervalDescription) (\(clauseTime).")
        return tptpTuples
    }
    
    static func axiomize(inout tptpTuples:[TptpNode.Tuple], functors:[(String, SymbolQuadruple)]) {
        let count = tptpTuples.count
        var counter = count
        
        let (_,axiomTime) = measure {
            
            let reflexivity = TptpNode(connective:"|",nodes: ["X=X"])
            let symmetry = "X!=Y | Y=X" as TptpNode
            let transitivity = "X!=Y | Y!=Z | X=Z" as TptpNode
            
            tptpTuples.append((reflexivity ** counter,-1,Yices.clause(reflexivity)))
            counter += 1
            tptpTuples.append((symmetry ** counter ,-1,Yices.clause(symmetry)))
            counter += 1
            tptpTuples.append((transitivity ** counter,-1,Yices.clause(transitivity)))
            counter += 1
            
            let maxArity = 200
            let variables = (1...maxArity).map {
                (TptpNode(variable:"X\($0)"),TptpNode(variable:"Y\($0)"))
            }
            
            
            
            for (symbol,quadruple) in functors {
                var arity = -1
                switch quadruple.arity {
                case .None:
                    assert(false)
                    break
                case .Fixed(let v):
                    arity = v
                    break
                case .Variadic(_):
                    assert(false)
                    break
                }
                
                assert(arity < maxArity)
                
                guard arity > 0 else {
                    // c == c
                    // ~p | p
                    continue
                }
                
                var literals = [TptpNode]()
                var xargs = [TptpNode]()
                var yargs = [TptpNode]()
                
                literals.reserveCapacity(arity)
                
                for i in 0..<arity {
                    let (X,Y) = variables[i]
                    let literal = TptpNode(equational:"!=", nodes:[X,Y])
                    literals.append(literal)
                    xargs.append(X)
                    yargs.append(Y)
                }
                switch quadruple.type {
                case .Predicate:
                    let npx = TptpNode(connective:"~", nodes:[TptpNode(predicate:symbol, nodes:xargs)])
                    let py = TptpNode(predicate:symbol, nodes:yargs)
                    literals.append(npx)
                    literals.append(py)
                case .Function:
                    let fx = TptpNode(function:symbol, nodes:xargs)
                    let fy = TptpNode(function:symbol, nodes:yargs)
                    let fx_eq_fy = TptpNode(equational:"=", nodes:[fx,fy])
                    literals.append(fx_eq_fy)
                default:
                    assert(false)
                    break
                }
                
                let congruence = TptpNode(connective:"|", nodes:literals)
                tptpTuples.append((congruence ** counter,-1,Yices.clause(congruence)))
                counter += 1
                
            }
        }
        print("\(tptpTuples.count-count) yices equality axioms in \(axiomTime.prettyTimeIntervalDescription) (\(axiomTime)).")
        
    }
    
    
    static func yiassert(ctx:COpaquePointer, tptpTuples:[TptpNode.Tuple]) {
        let (_,assertTime) = measure {
            for yiClause in tptpTuples {
                let code = yices_assert_formula(ctx,yiClause.2.0)
                assert( code >= 0 )
            }
        }
        print("\(tptpTuples.count) yices clauses asserted in \(assertTime.prettyTimeIntervalDescription) (\(assertTime)).")
    }
    
    static func yistatus(ctx:COpaquePointer, expected: smt_status_t?) -> smt_status_t {
        let status = yistatus(ctx)
        assert(expected == nil || status == expected!)
        return status
    }
    
    static func yistatus(ctx:COpaquePointer) -> smt_status_t {
        let (status, checkTime) = measure { yices_check_context(ctx,nil) }
        print("'yices_check_context(ctx,nil)' in \(checkTime.prettyTimeIntervalDescription).")
        return status
    }
    
    static func yimodel(ctx:COpaquePointer) -> COpaquePointer {
        
        let (mdl,modelTime) = measure {
            yices_get_model(ctx,1)
        }
        
        print("'yices_get_model(ctx,1)' in \(modelTime.prettyTimeIntervalDescription) (\(modelTime)).")
        return mdl
        
    }
    
    /// returns true if tptpTripl.selected has changed
    static func yiselect(mdl:COpaquePointer, tuple: TptpNode.Tuple) -> Int? {
        guard tuple.selected < 0 || yices_formula_true_in_model(mdl, tuple.triple.alignedYicesLiterals[tuple.selected]) == 0 else {
            return tuple.selected
        }
        
        var processedYicesLiterals = Set<term_t>()
        
        if tuple.selected >= 0 {
            processedYicesLiterals.insert(tuple.triple.alignedYicesLiterals[tuple.selected])
        }
        
        for yicesLiteral in tuple.triple.yicesLiterals {
            guard !processedYicesLiterals.contains(yicesLiteral) else {
                continue
            }
            
            let code = yices_formula_true_in_model(mdl, yicesLiteral)
            assert (code >= 0)
            
            guard code == 1 else {
                processedYicesLiterals.insert(yicesLiteral)
                continue
            }
            
            // sucess!
            
            guard let index = tuple.triple.alignedYicesLiterals.indexOf(yicesLiteral) else {
                assert(false,"yices literal \(yicesLiteral) is not aligned to '\(tuple)'")
                continue
            }
            return index
        }
        
        assert(false,"No literal of clause '\(tuple.node)' did hold in model.")
        return nil
        
    }
    
    static func eqfunc(symbols:[String : SymbolQuadruple]) -> (hasEquations:Bool, functors:[(String, SymbolQuadruple)]) {
        let hasEquations = symbols.reduce(false) { (a:Bool,b:(String,SymbolQuadruple)) in a || b.1.category == .Equational }
        let functors = symbols.filter { (a:String,q:SymbolQuadruple) in q.category == .Functor }
        return (hasEquations,functors)
    }
    
    static func demo() {
        for name in [
            "PUZ001-1",
            "PUZ001-2",
            "HWV074-1",
            "HWV066-1",
            "HWV119-1",
            "HWV105-1",
            "HWV124-1"
            ] {
                let file = name.p!
                let clauses = parse(file)
                
                let (_,runtime) = measure {
                    process(clauses)
                }
                
                print("\(#function) \(file) runtime = \(runtime.prettyTimeIntervalDescription) (\(runtime))")
                print("^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^")
        }
    }
    
    typealias ClauseIndices = (byYicesLiterals:[term_t:Set<Int>], byYicesClauses: [term_t:Set<Int>])
    
    static func addtoindices(inout clauseIndices:ClauseIndices, clauseIndex:Int, triple:Yices.Triple) {
        // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
        for yicesLiteral in Set(triple.alignedYicesLiterals) {
            if clauseIndices.byYicesLiterals[yicesLiteral] == nil {
                clauseIndices.byYicesLiterals[yicesLiteral] = Set<Int>()
            }
            
            clauseIndices.byYicesLiterals[yicesLiteral]?.insert(clauseIndex)
        }
        
        // ---------------------------------------------------------
        
        if clauseIndices.byYicesClauses[triple.yicesClause] == nil {
            clauseIndices.byYicesClauses[triple.yicesClause] = Set<Int>()
        }
        clauseIndices.byYicesClauses[triple.yicesClause]?.insert(clauseIndex)
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        
    }
    
    static func process(clauses:[TptpNode]) {
        var tptpTuples = construct(clauses)
        
        let (hasEquations, functors) = eqfunc(TptpNode.symbols)
        
        print(hasEquations ? "has equations" : "(has no equations)")
        
        
        if hasEquations { axiomize(&tptpTuples,functors:functors) }
        
        
        
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        yiassert(ctx,tptpTuples:tptpTuples)
        
        var status = yistatus(ctx, expected: STATUS_SAT)
        
        let mdl = yimodel(ctx)
        defer { yices_free_model(mdl) }
        
        var indexTrie = TrieClass<SymHop<String>,Int>()
        
        var tptpClauseIndexes : ClauseIndices = (byYicesLiterals:[term_t:Set<Int>](), byYicesClauses: [term_t:Set<Int>]())
        
        let start = CFAbsoluteTimeGetCurrent()
        let step = max(1,min(5000,tptpTuples.count/3))
        
        for (clauseIndex, tuple) in tptpTuples.enumerate() {
            let (tptpClause, selectedLiteralIndex, yicesTriple) = tuple
            let (yicesClause, _ , _) = yicesTriple
            
            if (clauseIndex % step == 0) {
                let time = CFAbsoluteTimeGetCurrent() - start
                print(clauseIndex,tptpClause,time.prettyTimeIntervalDescription)
            }
            
            addtoindices(&tptpClauseIndexes, clauseIndex: clauseIndex, triple: yicesTriple)
            
            assert(yices_formula_true_in_model(mdl, yicesClause) == 1)
            
            guard let newSelectedLiteralIndex = yiselect(mdl, tuple: tuple) else {
                assert(false)
                continue
            }
            
            if (newSelectedLiteralIndex != selectedLiteralIndex) {
                indexTrie.delete(selectedLiteralIndex)
                tptpTuples[clauseIndex].selected = newSelectedLiteralIndex   // update
            }
            
            let literal = tptpClause.nodes![newSelectedLiteralIndex]
            // print("\(clauseIndex).\(newSelectedLiteralIndex): '\(literal)' was selected from '\(tptpClause)'")
            
            // find complementaries
            
            if let candidates = candidateComplementaries(indexTrie,term: literal) {
                for candidate in candidates {
                    let otherClause = tptpTuples[candidate].node
                    let idx = tptpTuples[candidate].selected
                    let theliteral = otherClause.nodes![idx]
                    
                    let sigma = literal ~?= theliteral
                    
//                    print(" > \(candidate).\(idx) \t'\(theliteral)' of '\(otherClause)' ")
                    
                    if let mgu = sigma {
//                        print("\tµ=\t",mgu)
                        
                        let newtuples = construct([tptpClause * mgu, otherClause * mgu], baseIndex: tptpTuples.count)
                        
                        for newtuple in newtuples {
 //                           print("\t>>\t",newtuple)
                            
                            let (variantCandidatesByLiterals,variantCandidatesByClause) = variantSubsumptionCandidates(tptpClauseIndexes, newtuple.triple, tptpTuples: tptpTuples)
                            
                            let candidates = (variantCandidatesByClause ?? Set<Int>()).union(variantCandidatesByLiterals).sort()
                            let vs = candidates.map { (tptpTuples[$0].node, $0) }

//                            if vs.count > 0 {
//                                for v in vs { print("\t..\t",v) }
//                                print("\t__\t", variantCandidatesByLiterals ?? "'-'", variantCandidatesByClause ?? "'-'", "\t__")
//                            }
                        }
                    }
                    else {
//                        print("\t..\t are not complementary")
                    }
                }
            }
            
            for path in literal.paths {
                indexTrie.insert(path,value: clauseIndex)
            }
        }
    }
    
    static func variantSubsumptionCandidates(tptpClauseIndices: ClauseIndices, _ yicesTriple:Yices.Triple, tptpTuples: [TptpNode.Tuple] ) -> ([Int], Set<Int>?) {
        
        
        let newLiteralsSet = Set(yicesTriple.yicesLiterals)
        let literalSharer = tptpClauseIndices.byYicesLiterals.filter {
            newLiteralsSet.contains($0.0)
            }.flatMap { $0.1 }
        
        let candidatesByLiterals = Set(literalSharer).filter {
            candidateIndex in
            
            assert(candidateIndex < tptpTuples.count)
            
            let candidateLiteralsSet = Set(tptpTuples[candidateIndex].triple.alignedYicesLiterals)
            
            // the literals of a candidate must be a subset of the new literals (i.e. literals of a new clause)
            return candidateLiteralsSet.isSubsetOf(newLiteralsSet)
            
        }
        
        // ---------------------------------------------------------------------
        
        let candidatesByClause = tptpClauseIndices.byYicesClauses[yicesTriple.yicesClause]
        
        return (candidatesByLiterals, candidatesByClause)
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    }
}