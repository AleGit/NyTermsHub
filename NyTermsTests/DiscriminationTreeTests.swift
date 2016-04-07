//
//  DiscriminationTreeTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 07.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class DiscriminationTreeTests: XCTestCase {
    
    typealias DiscriminationTree = TrieClass<String,Int>

    func testBasics() {
        var dt = DiscriminationTree()
        
        let clauses : [TptpNode] = [
            "p(X)|p(Y)",
            "~p(X)|p(Y)",
            "~p(X)|p(Z)",
            "~p(Y)|p(Z)",
            "p(X)|~p(Y)",
            "p(X)|~p(Z)",
            "p(Y)|~p(Z)",
            "p(A)|p(B)"
        ]
        
        for (clauseIndex,clause) in clauses.enumerate() {
            print("\n:::",clauseIndex,clause,":::")
            
            guard let literals = clause.nodes else {
                XCTFail("\(clause) is not a clause")
                continue
            }
        
            var candidates = Set<Int>(0..<clauseIndex)
            
            let preorderPaths = literals.map { $0.preorderPath }
            
            for path in preorderPaths {
                
                if let result = dt.retrieve(path) {
                    candidates.intersectInPlace(result)
                }
                else {
                    candidates.removeAll()
                }
            }
            
            print(clauseIndex, Array(candidates).sort())
            
            for path in preorderPaths {
                
                dt.insert(path, value: clauseIndex)
            }
        }
        
        print()
        print(dt)
    }

}
