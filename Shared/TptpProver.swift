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

protocol ClauseProver {
    associatedtype Formula
    associatedtype Clause
    associatedtype Literal
    
    static func formulaeFromPath(path:String) -> [Formula]?
    static func clauseFromFormula(formula:Formula) -> Clause
    
    subscript(clauseIndex:Int) -> Clause? { get }
    subscript(clauseIndex:Int, literalIndex:Int) -> Literal? { get }

    init?<S:SequenceType where S.Generator.Element == Formula>(formulae:S)
}

extension ClauseProver {
    /// Try to create a prover for the given problem name, e.g. "PUZ001-1".
    /// When the file path for this problem name can not be found, no prover will be created.
    init?(problem name:String) {
        guard let path = name.p else {
            Nylog.log("Problem '\(name).p' could not be found.")
            return nil
        }
        
        self.init(file:path)
    }
    
    init?(file path:String) {
        guard let formulae = Self.formulaeFromPath(path) else { return nil }
        self.init(formulae: formulae)
    }
}

final class TptpProver : ClauseProver {
    typealias Formula = TptpFormula
    /// a pair of a tptp clause (with variables) and its grounded yices representation.
    typealias Clause = (TptpNode, Yices.Tuple)
    typealias Literal = (TptpNode, term_t)
    
    /// yices context pointer
    private let context : COpaquePointer
    
    /// names of clauses from problem file
    var clauseNames = [String]()
    
    /// roles of clauses from problem file, 
    /// new instances of clauses should get the roles of their ancestors.
    var clauseIndicesByRole = [TptpRole : Set<Int>]()
    
    /// a list of clauses, i.e. pairs of tptp clauses and corresponding ground (yices) clauses
    var clauses = [Clause]()
    
    init?<S:SequenceType where S.Generator.Element == Formula>(formulae:S) {
        context = yices_new_context(nil)
        // context is not an optional, but it is a C pointer and its value can be nil, i.e. NULL
        guard context != nil else { return nil }
        self.preprocess(formulae)
    }
    
    
    /// Try to create prover for file.
    /// When the file path is not accessible or parsing fails, no prover will be created.
//    convenience init?(file path:String) {
//        guard let formulae = self.pathToFormulae(path) else { return nil }
//        
//        self.init(formulae:formulae)
//    }
    
    deinit {
        yices_free_context(context)
    }
    
    // ========================
}

extension TptpProver {
    static func formulaeFromPath(path:String) -> [Formula]? {
        let (status, formulae, includes) = parse(path: path)
        
        let success = status.reduce( (status.count-1) == includes.count ) { $0 && $1 == 0 }
        
        guard success else {
            Nylog.log("Parse error \(status) on file '\(path)'")
            return nil
        }
        
        Nylog.log("\(formulae.count) formulae parsed (\(includes.count+1) file(s)).")
        
        return formulae
    }
    
    static func clauseFromFormula(formula:Formula) -> Clause {
        return (formula.root,Yices.clause(formula.root))
    }
}

extension TptpProver {
    subscript (clauseIndex:Int) -> Clause? {
        guard 0 <= clauseIndex && clauseIndex < clauses.count else { return nil }
        
        return clauses[clauseIndex]
    }
    
    subscript (clauseIndex:Int, literalIndex:Int) -> Literal? {
        guard let clause = self[clauseIndex] where 0 <= literalIndex
            && literalIndex <= clause.1.alignedYicesLiterals.count else { return nil }
        
        return (clause.0.nodes![literalIndex], clause.1.alignedYicesLiterals[literalIndex])
    }
}


extension TptpProver {
    private func register(clause index:Int, for role:TptpRole) {
        if clauseIndicesByRole[role] == nil {
            clauseIndicesByRole[role] = Set<Int>()
        }
        clauseIndicesByRole[role]?.insert(index)
    }
    
    func preprocess<S:SequenceType where S.Generator.Element == TptpFormula>(formulae:S) {
        for formula in formulae {
            let index = clauses.count
            
            clauseNames.append(formula.name)
            register(clause:index, for:formula.role)
            
            
            var clause = TptpProver.clauseFromFormula(formula)
            clause.0 = clause.0 ** index
            clauses.append(clause)
        }
    }
}
