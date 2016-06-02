//
//  ClauseProver.swift
//  NyTerms
//
//  Created by Alexander Maringele on 02.06.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

protocol ClauseProver {
    associatedtype Formula
    associatedtype Clause
    associatedtype Literal
    
    init?<S:SequenceType where S.Generator.Element == Formula>(formulae:S)
    
    var initTime : CFAbsoluteTime { get }
    var startTime : CFAbsoluteTime { get }
    
    static func formulaeFromPath(path:String) -> [Formula]?
    static func clauseFromFormula(formula:Formula) -> Clause
    
    func choose() -> Int?
    func select(clauseIndex:Int) -> Int?
    
    func indicate(clause index:Int, literal:Int)
    func deindicate(clause index:Int, literal:Int)
    
    subscript(clauseIndex:Int) -> Clause? { get }
    subscript(clauseIndex:Int, literalIndex:Int) -> Literal? { get }
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
    
    /// Try to create a prover from a given problem file, e.g. "/Users/Shared/TPTP/Problems/PUZ/PU0001-1.p"
    init?(file path:String) {
        guard let formulae = Self.formulaeFromPath(path) else { return nil }
        self.init(formulae: formulae)
    }
}
