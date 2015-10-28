//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

struct Yi {
    
    
    class Prover : NyTerms.Prover {
        private var tptpPath : String?
        private var tptpString : String?
        
        private var tptpFormulae : [TptpFormula]
        
        required init(path: String) {
            tptpPath = path
            
            let (_,formulae,_) = parse(path:tptpPath!)
            tptpFormulae = formulae
            
        }
        
        required init (string: String) {
            tptpString = string
            
            let (_,formulae) = parse(string:tptpString!)
            tptpFormulae = formulae
        }
        
        func run() -> Bool? {
            
            
            return nil
        }
        
    }
    
    class Context {
        
        private var ctx : COpaquePointer
        
        init() {
            ctx = yices_new_context(nil)
        }
        
        deinit {
            yices_free_context(ctx)
        }
        
        func add<N:Node>(clause:N) {
            assert(clause.isClause)
        
        }
        
        func add<N:Node>(clauses:[N]) {
            for clause in clauses {
                add(clause)
            }
            
        }
    }
}
