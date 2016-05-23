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
    static var printall = false
    static var printruntimes = false
    static var printcc = false
    static var printsummary = true
    
    
    static func parse(file:TptpPath) -> [TptpNode] {
        let (clauses,parseTime) = measure { TptpNode.roots(file) }
        doitif( printruntimes||printall ) {
            print("\(clauses.count) clauses parsed in \(parseTime.prettyTimeIntervalDescription) (\(parseTime) s).")
        }
        return clauses
    }
    
    static func construct(clauses:[TptpNode], baseIndex : Int = 0) -> [TptpNode.Tuple] {
        let (tptpTuples, clauseTime) = measure {
            clauses.enumerate().map { (node:$1 ** (baseIndex+$0), selected:-1,triple:Yices.clause($1.nodes!)) }
        }
        doitif( printall || (printruntimes && printcc) ) {
            print("\(tptpTuples.count) yices clauses constructed in \(clauseTime.prettyTimeIntervalDescription) (\(clauseTime).")
        }
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
        doitif( printruntimes||printall ) {
            print("\(tptpTuples.count-count) yices equality axioms in \(axiomTime.prettyTimeIntervalDescription) (\(axiomTime) s).")
        }
        
    }
    
    
    static func yiassert(ctx:COpaquePointer, tptpTuples:[TptpNode.Tuple]) {
        let (_,assertTime) = measure {
            for yiClause in tptpTuples {
                let code = yices_assert_formula(ctx,yiClause.2.0)
                assert( code >= 0 )
            }
        }
        doitif( printruntimes||printall ) {
            print("\(tptpTuples.count) yices clauses asserted in \(assertTime.prettyTimeIntervalDescription) (\(assertTime) s).")
        }
    }
    
    static func yistatus(ctx:COpaquePointer, expected: smt_status_t?) -> smt_status_t {
        let status = yistatus(ctx)
        assert(expected == nil || status == expected!)
        return status
    }
    
    static func yistatus(ctx:COpaquePointer) -> smt_status_t {
        let (status, checkTime) = measure { yices_check_context(ctx,nil) }
        doitif( printruntimes||printall ) {
            print("'yices_check_context(ctx,nil)' in \(checkTime.prettyTimeIntervalDescription).")
        }
        return status
    }
    
    static func yimodel(ctx:COpaquePointer) -> COpaquePointer {
        
        let (mdl,modelTime) = measure {
            yices_get_model(ctx,1)
        }
        
        doitif( printruntimes||printall ) {
            print("'yices_get_model(ctx,1)' in \(modelTime.prettyTimeIntervalDescription) (\(modelTime) s).")
        }
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
            // without equality
            // "PUZ001-1",
            "TOP019-1",
            
            // with equality
            // "PUZ063-1",
            // "PUZ063-2",
            
            // "PUZ043-1", // satisfiable
            //"PUZ056-2.030"
            // "PUZ001-2",
            // "HWV074-1",
            // "HWV066-1",
            // "HWV119-1",
            // "HWV105-1",
            // "HWV124-1"
            ] {
                guard let file = name.p else {
                    assert(false,"file '\(name)' was not found within tptp root path '\(TptpPath.tptpRootPath)'.")
                    continue
                }
                let clauses = parse(file)
                
                let (_,runtime) = measure {
                    process(clauses)
                }
                
                doitif( printsummary ) {
                    print("\(#function) \(file) runtime = \(runtime.prettyTimeIntervalDescription) (\(runtime))")
                }
                print("^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^")
        }
    }
    
    typealias ClauseIndices = (byYicesLiterals:[term_t:Set<Int>], byYicesClauses: [term_t:Set<Int>])
    
    static func addtoclauseindices(inout clauseIndices:ClauseIndices, clauseIndex:Int, triple:Yices.Triple) {
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
        
        doitif( printall ) {
            print(hasEquations ? "has equations" : "(has no equations)")
        }
        
        
        if hasEquations { axiomize(&tptpTuples,functors:functors) }
        
        
        
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        yiassert(ctx,tptpTuples:tptpTuples)
        
        var status = yistatus(ctx, expected: STATUS_SAT)
        
        var indexTrie = TrieClass<SymHop<String>,Int>()
        
        var tptpClauseIndexes : ClauseIndices = (byYicesLiterals:[term_t:Set<Int>](), byYicesClauses: [term_t:Set<Int>]())
        
        var proofTree = [Int : (lcidx:Int,rcidx:Int,mgu:[TptpNode:TptpNode])]()
        
        let start = CFAbsoluteTimeGetCurrent()
        let step = max(1,min(5000,tptpTuples.count/3))
        
        var processed = -1
        
        while status == STATUS_SAT {
            
            print("***",status,"(begin)", tptpTuples.count)
            let count = tptpTuples.count
            let mdl = yimodel(ctx)
            defer {
                yices_free_model(mdl)
                status = yistatus(ctx)
                print("***",status,"(end)", tptpTuples.count)
            }
            
            for (clauseIndex, tuple) in tptpTuples.enumerate() {
                
                let (tptpClause, selectedLiteralIndex, yicesTriple) = tuple
                let (yicesClause, _ , _) = yicesTriple
                
                doitif( printall || (clauseIndex % step == 0 && printruntimes) ) {
                    let time = CFAbsoluteTimeGetCurrent() - start
                    print(clauseIndex,tptpClause,time.prettyTimeIntervalDescription,"(\(time) s)")
                }
                
                if clauseIndex > processed {
                    addtoclauseindices(&tptpClauseIndexes, clauseIndex: clauseIndex, triple: yicesTriple)
                    processed = clauseIndex
                }
                
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
                doitif( printall ) {
                    print("\(clauseIndex).\(newSelectedLiteralIndex): '\(literal)' was selected from '\(tptpClause)'")
                }
                
                // find complementaries
                
                if let candidates = candidateComplementaries(indexTrie,term: literal) {
                    for candidate in candidates {
                        let otherClause = tptpTuples[candidate].node
                        let idx = tptpTuples[candidate].selected
                        let theliteral = otherClause.nodes![idx]
                        
                        let sigma = literal ~?= theliteral
                        
                        doitif( printall ) {
                            print(" > \(candidate).\(idx) \t'\(theliteral)' of '\(otherClause)' ")
                        }
                        
                        if let mgu = sigma {
                            doitif( printall ) {
                                print("\tµ=\t",mgu)
                            }
                            
                            for possibleNewClause in [tptpClause * mgu, otherClause * mgu] {
                                guard let µ = possibleNewClause =?= tptpClause where !µ.isRenaming else {
                                    continue
                                }
                                
                                let newtuples = construct([possibleNewClause], baseIndex: tptpTuples.count)
                                assert(newtuples.count == 1)
                                
                                guard let newtuple = newtuples.first else {
                                    continue
                                }
                                
                                doitif( printall ) {  print("\t>>\t",newtuple) }
                                
                                let (variantCandidatesByLiterals,variantCandidatesByClause) = variantSubsumptionCandidates(tptpClauseIndexes, newtuple.triple, tptpTuples: tptpTuples)
                                
                                doitif( printall ) {
                                    let candidates = (variantCandidatesByClause ?? Set<Int>()).union(variantCandidatesByLiterals).sort()
                                    let vs = candidates.map { (tptpTuples[$0].node, $0) }
                                    
                                    
                                    if vs.count > 0 {
                                        for v in vs { print("\t..\t",v) }
                                        print("\t__\t", variantCandidatesByLiterals ?? "'-'", variantCandidatesByClause ?? "'-'", "\t__")
                                    }
                                    
                                }
                                
                                guard variantCandidatesByLiterals.isEmpty else { continue }
                                
                                print("\(clauseIndex) addd \(newtuple)")
                                tptpTuples.append(newtuple)
                                
                                yiassert(ctx,tptpTuples:newtuples)
                                
                                guard yistatus(ctx, expected: nil) == STATUS_SAT else {
                                    print("contradiction: \(newtuple)")
                                    break
                                }
                                
                                if clauseIndex > processed {
                                    addtoclauseindices(&tptpClauseIndexes, clauseIndex: clauseIndex, triple: newtuple.triple)
                                    processed = clauseIndex
                                }
                                
                                
                            }
                        }
                        else {
                            doitif( printall ) {
                                print("\t..\t are not complementary")
                            }
                        }
                    }
                }
                
                for path in literal.paths {
                    indexTrie.insert(path,value: clauseIndex)
                }
            }
            
            guard count < tptpTuples.count else { break }
            
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