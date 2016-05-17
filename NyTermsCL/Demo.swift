//
//  File.swift
//  NyTerms
//
//  Created by Alexander Maringele on 13.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation


struct Demo {
    static func demo() {
        let file = "PUZ001-2".p!
        // let file = "HWV124-1".p!
        // let file = "HWV134-1".p!
        print(file)
        
        
        // MARK: scan and parse
        let (clauses,parseTime) = measure { TptpNode.roots(file) }
        print("\(clauses.count) clauses parsed in \(parseTime.prettyTimeIntervalDescription).")
        
        
        // MARK: construct
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        var (yiClauses, clauseTime) = measure {
            clauses.map { ($0, Yices.clause($0.nodes!)) }
        }
        print("\(yiClauses.count) yices clauses constructed in \(clauseTime.prettyTimeIntervalDescription).")
        
        
        
        let (_,axiomTime) = measure {
            
            
            
 
            // MARK: handle equality
            let reflexivity = TptpNode(connective:"|",nodes: ["X=X"])
            let symmetry = "X!=Y | Y=X" as TptpNode
            let transitivity = "X!=Y | Y!=Z | X=Z" as TptpNode
            
            yiClauses.append((reflexivity,Yices.clause(reflexivity)))
            yiClauses.append((symmetry,Yices.clause(symmetry)))
            yiClauses.append((transitivity,Yices.clause(transitivity)))
            
            let maxArity = 20
            let variables = (1...maxArity).map {
                (TptpNode(variable:"X\($0)"),TptpNode(variable:"Y\($0)"))
            }
            
            for (symbol,quadruple) in TptpNode.symbols {
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
                yiClauses.append((congruence,Yices.clause(congruence)))
                
            }
        }
        print("\(yiClauses.count-clauses.count) yices equality axioms in \(axiomTime.prettyTimeIntervalDescription).")
       
        
        
        // MARK: assert
        let (_,assertTime) = measure {
            for (index,yiClause)in yiClauses.enumerate() {
                
                
                assert( yices_assert_formula(ctx,yiClause.1.0) >= 0 )
                
            }
        }
        print("\(yiClauses.count) yices clauses asserted in \(assertTime.prettyTimeIntervalDescription).")
        
        
        //        for (index,yiClause) in yiClauses[clauses.count..<yiClauses.count].enumerate() {
        //            print(index+clauses.count,yiClause)
        //        }
        
        // MARK: check and model
        
        let (status, checkTime) = measure { yices_check_context(ctx,nil) }
        print("yices check context in \(checkTime.prettyTimeIntervalDescription).")
        assert(status == STATUS_SAT)
        
        let (mdl,modelTime) = measure {
            yices_get_model(ctx,1)
        }
        defer {
            yices_free_model(mdl)
        }
        print("yices get model in \(modelTime.prettyTimeIntervalDescription).")
        
        //        for (key,value) in TptpNode.symbols {
        //            print(key,value)
        //        }
        
        print("===================================================================================================")
        
        print("\(clauses.count) clauses parsed in \(parseTime.prettyTimeIntervalDescription).")
        print("\(clauses.count) yices clauses constructed in \(clauseTime.prettyTimeIntervalDescription).")
        print("\(yiClauses.count-clauses.count) yices equality axioms in \(axiomTime.prettyTimeIntervalDescription).")
        print("\(yiClauses.count) yices clauses asserted in \(assertTime.prettyTimeIntervalDescription).")
        print("yices check context in \(checkTime.prettyTimeIntervalDescription).")
        print("yices get model in \(modelTime.prettyTimeIntervalDescription).")
        
        
    }
}