//
//  TptpProver.swift
//  NyTerms
//
//  Created by Alexander Maringele on 30.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

//extension TptpRole : Hashable {
//    public var hashValue : Int {
//        return self.rawValue.hashValue
//    
//    }
//}



final class TptpProver {
    typealias ProverTuple = (TptpNode, Yices.Tuple)
    
    private let context : COpaquePointer
    
    var names = [String]()
    var clauseIndicesByRole = [TptpRole : Set<Int>]()
    var repository = [ProverTuple]()
    
    
    init?(problem:String) {
        guard let path = problem.p else {
            Nylog.log("Problem file '\(problem).p' could not be found.")
            return nil
        }
        
        let (status, formulae, includes) = parse(path: path)
        
        let success = status.reduce( (status.count-1) == includes.count ) { $0 && $1 == 0 }
        
        guard success else {
            Nylog.log("Parse error \(status) on file '\(path)'")
            return nil
        }
        
        Nylog.log("\(formulae.count) formulae parsed (\(includes.count+1) file(s)).")
        
        context = yices_new_context(nil)
        guard context != nil else { return nil }
        
        preprocess(formulae)
    }
    
    deinit {
        yices_free_context(context)
    }
    
    // ========================
    
    
}

extension TptpProver {
    func preprocess(formulae:[TptpFormula]) {
        for (index,formula) in formulae.enumerate() {
            names.append(formula.name)
            
            var clauseIndices = clauseIndicesByRole[formula.role] ?? Set<Int>()
            clauseIndices.insert(index)
            clauseIndicesByRole[formula.role] = clauseIndices
            
            repository.append((formula.root ** index, Yices.clause(formula.root)))
        }
    }
}
