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



//final class TptpProver : ClauseProver {
//    typealias Formula = TptpFormula
//    /// a pair of a tptp clause (with variables) and its grounded yices representation.
//    typealias Clause = (node:TptpNode, literalIndex:Int?, yices:Yices.Tuple)
//    typealias Literal = (node:TptpNode, yices:term_t)
//    
//    /// yices context pointer
//    private let context : COpaquePointer
//    
//    /// names of clauses from problem file
//    var clauseNames = [String]()
//    
//    /// roles of clauses from problem file,
//    /// new instances of clauses should get the roles of their ancestors.
//    var clauseIndicesByRole = [TptpRole : Set<Int>]()
//    var clauseIndicesBySelectedYicesLiterals = [term_t : Set<Int>]()  // find complementaries
//    var clauseIndicesByAllYicesLiterals = [term_t : Set<Int>]()      // check for variants
//    
//    /// a list of clauses, i.e. pairs of tptp clauses and corresponding ground (yices) clauses
//    var clauses = [Clause]()
//    
//    /// a set of unit clauses
//    var unitClauseIndices = Set<Int>()
//    var inactiveClauseIndices = Set<Int>()
//    
//    init?<S:SequenceType where S.Generator.Element == Formula>(formulae:S) {
//        context = yices_new_context(nil)
//        // context is not an optional, but it is a C pointer and its value can be nil, i.e. NULL
//        guard context != nil else { return nil }
//        self.preprocess(formulae)
//    }
//    
//    func run(timeout:CFTimeInterval = 30.0) -> smt_status_t {
//        var status = yices_check_context(context,nil)
//        
//        while status == STATUS_SAT {
//            let model = yices_get_model(context,1)
//            defer {
//                yices_free_model(model)
//                status = yices_check_context(context,nil)
//            }
//            
//            guard let clauseIndex = selectClauseIndex() else {
//                return yices_check_context(context,nil)
//            }
//            
//            let clauseIndices = activate(clause:clauseIndex)
//            
//            
//        }
//        
//        return yices_check_context(context,nil)
//        
//    }
//    
//    func activate(clause index:Int) -> Set<Int> {
//        var clauseIndices = Set<Int>()
//        defer {
//            inactiveClauseIndices.remove(index)
//            indicate(clause:index)
//        }
//        
//        let entry = clauses[index]
//        
//        gua
//    }
//    
//    
//    /// Try to create prover for file.
//    /// When the file path is not accessible or parsing fails, no prover will be created.
//    //    convenience init?(file path:String) {
//    //        guard let formulae = self.pathToFormulae(path) else { return nil }
//    //
//    //        self.init(formulae:formulae)
//    //    }
//    
//    func selectClauseIndex() -> Int? {
//        return unitClauseIndices.intersect(inactiveClauseIndices).first ?? inactiveClauseIndices.first
//    }
//    
//    deinit {
//        yices_free_context(context)
//    }
//    
//    // ========================
//}
//
//extension TptpProver {
//    static func formulaeFromPath(path:String) -> [Formula]? {
//        let (status, formulae, includes) = parse(path: path)
//        
//        let success = status.reduce( (status.count-1) == includes.count ) { $0 && $1 == 0 }
//        
//        guard success else {
//            Nylog.log("Parse error \(status) on file '\(path)'")
//            return nil
//        }
//        
//        Nylog.log("\(formulae.count) formulae parsed (\(includes.count+1) file(s)).")
//        
//        return formulae
//    }
//    
//    static func clauseFromFormula(formula:Formula) -> Clause {
//        return (formula.root, nil, Yices.clause(formula.root))
//    }
//}
//
//extension TptpProver {
//    subscript (clauseIndex:Int) -> Clause? {
//        guard 0 <= clauseIndex && clauseIndex < clauses.count else { return nil }
//        
//        return clauses[clauseIndex]
//    }
//    
//    subscript (clauseIndex:Int, literalIndex:Int) -> Literal? {
//        guard let clause = self[clauseIndex] where 0 <= literalIndex
//            && literalIndex <= clause.2.alignedYicesLiterals.count else { return nil }
//        
//        return (clause.0.nodes![literalIndex], clause.2.alignedYicesLiterals[literalIndex])
//    }
//}
//
//
//extension TptpProver {
//    private func indicate(clause index:Int, yices literal: term_t, inout list:[term_t:Set<Int>]) {
//        if list[literal] == nil {
//            list[literal] = Set<Int>()
//        }
//        list[literal]?.insert(index)
//    }
//    
//    private func deindicate(clause index:Int, yices literal: term_t, inout list:[term_t:Set<Int>]) {
//        list[literal]?.remove(index)
//    }
//    
//    func indicate(clause index:Int, selected:Bool = true) {
//        let entry = clauses[index]
//        
//        
//        for literal in entry.yices.yicesLiterals {
//            indicate(clause:index, yices:literal, list: &clauseIndicesByAllYicesLiterals)
//        }
//        
//        guard let literalIndex = entry.literalIndex
//            where literalIndex < entry.yices.alignedYicesLiterals.count else {
//                return
//        }
//        
//        let literal = entry.yices.alignedYicesLiterals[literalIndex]
//        
//        indicate(clause:index, yices:literal, list: &clauseIndicesBySelectedYicesLiterals)
//    }
//    
//    func deindicate(clause index:Int, selected:Bool = true) {
//        let entry = clauses[index]
//        for literal in entry.yices.yicesLiterals {
//            deindicate(clause:index, yices:literal, list: &clauseIndicesByAllYicesLiterals)
//        }
//        
//        guard let literalIndex = entry.literalIndex
//            where literalIndex < entry.yices.alignedYicesLiterals.count else {
//                return
//        }
//        
//        let literal = entry.yices.alignedYicesLiterals[literalIndex]
//        
//        deindicate(clause:index, yices:literal, list: &clauseIndicesBySelectedYicesLiterals)
//        
//        
//        
//    }
//    
//    private func register(clause index:Int, for role:TptpRole) {
//        if clauseIndicesByRole[role] == nil {
//            clauseIndicesByRole[role] = Set<Int>()
//        }
//        clauseIndicesByRole[role]?.insert(index)
//    }
//    
//    func yicesSelect(clause index:Int, model: COpaquePointer) -> Bool {
//        let entry = clauses[index]
//        
//        if let lidx = entry.literalIndex where yices_formula_true_in_model(model, entry.yices.alignedYicesLiterals[lidx]) == 1 {
//            return false // nothing has changed
//        }
//        
//        deindicate(clause:index)
//        
//        for lidx in entry.yices.yicesLiterals {
//            guard yices_formula_true_in_model(model, lidx) == 0 else {
//                clauses[index].literalIndex = entry.yices.alignedYicesLiterals.indexOf(lidx)
//                
//                assert(clauses[index].literalIndex != nil)
//                
//                return true
//            }
//        }
//        
//        assert(false)
//        return true
//    }
//    
//    func yicesAssert(clause index:Int) {
//        let entry = clauses[index]
//        let code = yices_assert_formula(context, entry.2.yicesClause)
//        assert(code >= 0)
//        
//        inactiveClauseIndices.insert(index)
//        
//        if entry.yices.alignedYicesLiterals.count == 1 {
//            unitClauseIndices.insert(index)
//            
//            // it is a unit clause, hence the first (and only) literal is selected
//            
//            clauses[index].literalIndex = 0
//        }
//        else if entry.yices.yicesLiterals.count == 1 {
//            // the relevant literals are variants of each other : x ≥ y | y ≥ x
//            // or the clause is trivially true ~p(x) | p(x)
//            
//            if let lid = entry.yices.yicesLiterals.first,
//                let lidx = entry.yices.alignedYicesLiterals.indexOf(lid) {
//                clauses[index].literalIndex = lidx
//                return
//            }
//        }
//        
//        // at this point we do not know which literal will be selected
//    }
//    
//    func preprocess<S:SequenceType where S.Generator.Element == TptpFormula>(formulae:S) {
//        for formula in formulae {
//            let index = clauses.count
//            
//            clauseNames.append(formula.name)
//            register(clause:index, for:formula.role)
//            
//            var clause = TptpProver.clauseFromFormula(formula)
//            clause.0 = clause.0 ** index // make clauses variable distinct by adding the index as suffix
//            clauses.append(clause)
//            
//            yicesAssert(clause:index)
//        }
//    }
//}
