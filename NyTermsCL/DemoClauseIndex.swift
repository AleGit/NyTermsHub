//
//  DemoClauseIndex.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

struct DemoClauseIndex {
    static func demo(name:String) {
        typealias N = TptpNode
        guard let path = name.p else {
            print("\(name) could not be found")
            return
        }
        
        print(path)
        
        var repository = [(N, term_t, Set<term_t>, [term_t])]()
        var literalsClauseIndex = [ term_t : Set<Int>]() // yices literal : set of claus indices
        var clauseIndex = [ term_t : Set<Int>]()
        
        let clauses = TptpNode.roots(path)
        
        for (index,clause) in clauses.enumerate() {
            
            let (yicesClause,yicesLiterals,alignedYicesLiterals) = Yices.clause(clause)
            
            repository.append((clause,yicesClause,yicesLiterals,alignedYicesLiterals))
            
            // === find candidates for variants by literal clause indes
            
            
            var candis = Set<Int>(0..<index) // all clause so far are candidates
            
            for value in yicesLiterals {
                guard let entry = literalsClauseIndex[value] else {
                    candis.removeAll()
                    break
                }
                candis.intersectInPlace(entry)
            }
            
            var ciyc = clauseIndex[yicesClause] ?? Set<Int>()
            
            // assert (candis.isSupersetOf(ciyc), "\(candis), \(ciyc)")
            
            if candis != ciyc {
                print("=== ====")
                print("\(index)(\(yicesClause)), \(clause),\(yicesLiterals) :", (candis.count, ciyc.count))
                for (label,set) in [
                    ("candis only",candis.subtract(ciyc)),
                    ("ciyc only", ciyc.subtract(candis)),
                    ("both",candis.intersect(ciyc))] {
                    
                        guard set.count > 0 else {
                            continue
                        }
                        
                        print(label)
                        for entry in set {
                            let e = repository[entry]
                            print("\(entry)(\(e.2)), \(e.0),\(e.3)")
                        }
                }
            }
            
            
            
            
            // insert into literal clause index
            for value in yicesLiterals
            {
                guard var entry = literalsClauseIndex[value] else {
                    literalsClauseIndex[value] = Set(arrayLiteral:index)
                    continue
                }
                
                entry.insert(index)
                literalsClauseIndex[value] = entry
            }
            
            // === 
            
            // insert into clause index
            ciyc.insert(index)
            clauseIndex[yicesClause] = ciyc
            
            
            
            
            
            
            
        }
        
        
    }
}
