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
        
        var repository = [(N,[N], term_t, [term_t], Int?)]()
        var clauseIndex = [ term_t : Set<Int>]() // yices literal : set of claus indices
        
        let clauses = TptpNode.roots(path)
        
        for (index,clause) in clauses.enumerate() {
            
            let (ls,yc,yls,i) = Yices.clause(clause)
            
            repository.append((clause,ls,yc,yls,i))
            
            // find candidates for variants
            
            let keys = Set(yls)
            
            var candis = Set<Int>(0..<index) // all clause so far are candidates
            
            for value in keys {
                guard let entry = clauseIndex[value] else {
                    candis.removeAll()
                    break
                }
                candis.intersectInPlace(entry)
            }
            
            if !candis.isEmpty {
                print(index, clause, candis)
            }
            
            
            // insert into clause index
            for value in keys {
                guard var entry = clauseIndex[value] else {
                    clauseIndex[value] = Set(arrayLiteral:index)
                    continue
                }
                
                entry.insert(index)
                clauseIndex[value] = entry
            }
            
            
            
            
            
        }
        
        
    }
}
