//
//  File.swift
//  NyTerms
//
//  Created by Alexander Maringele on 13.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation


typealias YicesClause = (node:TptpNode,selected:Int,triple:Yices.Triple)

struct Demo {
    static func parse(file:TptpPath) -> [TptpNode] {
        let (clauses,parseTime) = measure { TptpNode.roots(file) }
        print("\(clauses.count) clauses parsed in \(parseTime.prettyTimeIntervalDescription).")
        return clauses
    }
    
    static func construct(clauses:[TptpNode]) -> [YicesClause] {
        let (yiClauses, clauseTime) = measure {
            clauses.enumerate().map { (node:$1 ** $0, selected:-1,triple:Yices.clause($1.nodes!)) }
        }
        print("\(yiClauses.count) yices clauses constructed in \(clauseTime.prettyTimeIntervalDescription).")
        return yiClauses
    }
    
    static func axiomize(inout yiClauses:[YicesClause], functors:[(String, SymbolQuadruple)]) {
        let count = yiClauses.count
        var counter = count
        
        let (_,axiomTime) = measure {
            
            let reflexivity = TptpNode(connective:"|",nodes: ["X=X"])
            let symmetry = "X!=Y | Y=X" as TptpNode
            let transitivity = "X!=Y | Y!=Z | X=Z" as TptpNode
            
            yiClauses.append((reflexivity ** counter,-1,Yices.clause(reflexivity)))
            counter += 1
            yiClauses.append((symmetry ** counter ,-1,Yices.clause(symmetry)))
            counter += 1
            yiClauses.append((transitivity ** counter,-1,Yices.clause(transitivity)))
            counter += 1
            
            let maxArity = 20
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
                yiClauses.append((congruence ** counter,-1,Yices.clause(congruence)))
                counter += 1
                
            }
        }
        print("\(yiClauses.count-count) yices equality axioms in \(axiomTime.prettyTimeIntervalDescription).")
        
    }
    
    
    static func yiassert(ctx:COpaquePointer, yiClauses:[YicesClause]) {
        let (_,assertTime) = measure {
            for yiClause in yiClauses {
                let code = yices_assert_formula(ctx,yiClause.2.0)
                assert( code >= 0 )
            }
        }
        print("\(yiClauses.count) yices clauses asserted in \(assertTime.prettyTimeIntervalDescription).")
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
        
        print("'yices_get_model(ctx,1)' in \(modelTime.prettyTimeIntervalDescription).")
        return mdl
        
    }
    
    
    
    static func demo() {
        for name in [// "PUZ001-1",
            "PUZ001-2", // "HWV124-1"
            ] {
                let file = name.p!
                let clauses = parse(file)
                var yiClauses = construct(clauses)
                
                let hasEquations = TptpNode.symbols.reduce(false) { (a:Bool,b:(String,SymbolQuadruple)) in a || b.1.category == .Equational }
                let functors = TptpNode.symbols.filter { (a:String,q:SymbolQuadruple) in q.category == .Functor }
                
                if hasEquations { axiomize(&yiClauses,functors:functors) }
                print("\(file)", hasEquations ? "has equations" : "(has no equations)")
                
                
                let ctx = yices_new_context(nil)
                defer { yices_free_context(ctx) }
                
                yiassert(ctx,yiClauses:yiClauses)
                
                var status = yistatus(ctx, expected: STATUS_SAT)
                
                let mdl = yimodel(ctx)
                defer { yices_free_model(mdl) }
                
                var indexTrie = TrieClass<SymHop<String>,Int>()
                
                for (clauseIndex,yicesClause) in yiClauses.enumerate() {
                    
                    let (node,selectedLiteralIndex,triple) = yicesClause
                    let (yiClause,yiLiterals,yiLiteralsBefore) = triple
                    
                    assert(yices_formula_true_in_model(mdl, yiClause) == 1)
                    
                    for (literalIndex, yiLiteral) in yiLiterals.enumerate() {
                        if yices_formula_true_in_model(mdl, yiLiteral) == 1 {
                            
                            
                            if (literalIndex != selectedLiteralIndex) {
                                if selectedLiteralIndex >= 0 {
                                    indexTrie.delete(selectedLiteralIndex)
                                }
                                
                                if let newSelectedIndex = yiLiteralsBefore.indexOf(yiLiteral) {
                                    yiClauses[clauseIndex].selected = newSelectedIndex
                                    
                                    let literal = node.nodes![newSelectedIndex]
                                    
                                    print("\(clauseIndex).\(newSelectedIndex): '\(literal)' was selected from '\(node)'")
                                    
                                    // find complementaries
                                    
                                    if let candidates = candidateComplementaries(indexTrie,term: literal) {
                                        for candidate in candidates {
                                            let theNode = yiClauses[candidate].node
                                            let idx = yiClauses[candidate].selected
                                            let theliteral = theNode.nodes![idx]
                                            
                                            let sigma = literal ~?= theliteral
                                            
                                            print(" > \(candidate).\(idx) \t'\(theliteral))' of '\(node)') ")
                                            
                                            if let mgu = sigma {
                                                print("\t>>\t",mgu)
                                                print("\t>>\t",node * mgu)
                                                print("\t>>\t",theNode * mgu)
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                    for path in literal.paths {
                                        indexTrie.insert(path,value: clauseIndex)
                                    }
                                    
                                }
                                else {
                                    assert(yiLiteral == yiClause)
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
                
                
                print("^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^")
                
                
                
                
                
        }
    }
}