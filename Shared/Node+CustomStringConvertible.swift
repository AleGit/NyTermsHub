//
//  Node+CustomStringConvertible.swift
//  NyTerms
//
//  Created by Alexander Maringele on 17.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Node {
    
    /// Clumsy attempt to make descriptions flexible.
    func buildDescription(_ decorate:(symbol:Symbol,type:SymbolType)->String) -> String {
        let separator = ","
        
        guard let nodes = self.nodes else {
            // since self has not list of subnodes at all,
            // self must be a variable term
            assert((self.symbolType ?? SymbolType.variable) == SymbolType.variable, "\(self.symbolString) is variable term with wrong type \(self.symbolQuadruple())!)")
            
            return decorate(symbol:self.symbol, type:SymbolType.variable)
        }
        
        let decors = nodes.map { $0.buildDescription(decorate) }
        
        guard let quartuple = self.symbolQuadruple() else {
            // If the symbol is not defined in the global symbol table,
            // i.e. a function or predicate symbol
            let decor = decorate(symbol:self.symbol,type:SymbolType.function)
            
            // we assume prefix notation for (constant) functions or predicates:
            switch nodes.count {
            case 0:
                return "\(decor)" // constant (or proposition)
            default:
                return "\(decor)(\(decors.joined(separator: separator)))" // prefix function (or predicate)
            }
        }
        
        assert(quartuple.arity.contains(nodes.count), "'\(self.symbolDebugString)' has invalid number \(nodes.count).")
        
        let decor = decorate(symbol:self.symbol, type:quartuple.type)
        
        switch quartuple {
            
        case (.universal,_,.tptpSpecific,_), (.existential,_,.tptpSpecific,_):
            return "(\(decor)[\(decors.first!)]:(\(decors.last!)))" // e.g.: ! [X,Y,Z] : ( P(f(X,Y),Z) & f(X,X)=g(X) )
            
        case (_,_,.tptpSpecific,_):
            assertionFailure("\(self.symbolDebugString)' has ambiguous notation.")
            return "\(decor)☇(\(decors.joined(separator: ",")))"
            
        case (.universal,_,_,_), (.existential,_,_,_):
            return "(\(decor)\(decors.first!) (\(decors.last!)))" // e.g.: ∀ x,y,z : ( P(f(x,y),z) ∧ f(x,x)=g(x) )
            
        case (_,_,.prefix,_) where nodes.count == 0:
            return "\(decor)"
            
        case (_,_,.prefix,_):
            return "\(decor)(\(decors.joined(separator: separator)))"
            
        case (_,_,.minus,_) where nodes.count == 1:
            return "\(decor)(\(decors.first!)"
            
        case (_,_,.minus,_), (_,_,.infix,_):
            return decors.joined(separator: decor)
            
        case (_,_,.postfix,_):
            assertionFailure("'\(symbolDebugString),\(decor)' uses unsupported postfix notation.")
            return "(\(decors.joined(separator: separator)))\(decor)"
            
        case (_,_,.invalid,_):
            assertionFailure("'\(symbolDebugString),\(decor)' has invalid notation.")
            return "☇\(decor)☇(\(decors.joined(separator: separator)))"
            
        default:
            assertionFailure("'\(symbolDebugString)' has impossible notation.")
            return "☇☇\(decor)☇☇(\(decors.joined(separator: separator)))"
        }
    }
}
