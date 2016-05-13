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
        
        print(file)
        let (clauses,r0) = measure { TptpNode.roots(file) }
        
        print("\(clauses.count) clauses parsed in \(r0.prettyTimeIntervalDescription).")
        
        
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        let (yiClauses, r1) = measure {
            clauses.map { ($0, Yices.clause($0.nodes!)) }
        }
        
        print("\(yiClauses.count) yices clauses constructed in \(r1.prettyTimeIntervalDescription).")
        
        for (index,yiClause)in yiClauses.enumerate() {
            print(index, yiClause.1, yiClause.0)
            
            assert( yices_assert_formula(ctx,yiClause.1.0) >= 0 )
            
        }
        
        let (status, r2) = measure { yices_check_context(ctx,nil) }
        print("yices check context in \(r2.prettyTimeIntervalDescription).")
        assert(status == STATUS_SAT)
        
        let mdl = yices_get_model(ctx,1)
        defer {
            yices_free_model(mdl)
        }
        
        
        
        
    }
}