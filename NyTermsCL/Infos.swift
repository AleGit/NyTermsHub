//
//  Infos.swift
//  NyTerms
//
//  Created by Alexander Maringele on 29.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

struct Infos {
    static let files = [
        // problem :( formualae, literals, complementaries)
        "PUZ001-1" : (     12,      21, 21),
        "HWV066-1" : (  15233,   35166, 109117),
        "HWV074-1" : (   2581,    6017, 78115),
        "HWV105-1" : (  20900,   52662, 234826),    // 13 s
        "HWV119-1" : (  17783,   53121, 563536),
        "HWV134-1" : (2332428, 6570884, 0)
    ]
}

extension Infos {
    static func demo() {
        for (name,_) in Infos.files {
            let path = name.p!
            let (clauses,parsetime) = measure { TptpNode.roots(path) }
            print("\(path) parsed in \(parsetime.prettyTimeIntervalDescription).")
            let (yicesClauses,maptime) = measure { clauses.map {
                (clause) -> term_t in
                let (yc, yls, ylbs) = Yices.clause(clause)
                
                let yicesLiteralsSet = Set(yls)
                let alignedYicesLiteralsSet = Set(ylbs)
                
                //            if yicesLiterals.elementCounts != alignedYicesLiterals.elementCounts {
                //                assert(yicesLiteralsSet.isSupersetOf(alignedYicesLiteralsSet))
                //                print("\(yicesLiterals) <- \(alignedYicesLiterals)")
                //            }
                let added = yicesLiteralsSet.subtract(alignedYicesLiteralsSet    )
                if added.count > 0 {
                    print("added:",added,"\(yls) <- \(ylbs)")
                }
                let removed = alignedYicesLiteralsSet.subtract(yicesLiteralsSet)
                if removed.count > 0 {
                    let removedLiterals = ylbs.enumerate().filter {
                        removed.contains($0.1)
                        }.map {
                            clause.nodes![$0.0]
                    }
                    
                    print("removed:",removed,"* \(yls) <- \(ylbs)", removedLiterals)
                }
                
                return yc
                }
            }
            print("\(yicesClauses.count) clauses mapped in \(maptime.prettyTimeIntervalDescription).")
        }
        
    }
}


