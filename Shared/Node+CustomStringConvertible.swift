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
    func buildDescription(decorate:(symbol:Symbol,type:SymbolType)->String) -> String {
        let separator = ","
        
        guard let nodes = self.nodes else {
            // since self has not list of subnodes at all,
            // self must be a variable term
            assert((self.symbolType ?? SymbolType.Variable) == SymbolType.Variable, "\(self.symbolString) is variable term with wrong type \(self.symbolQuadruple)!)")
            
            return decorate(symbol:self.symbol, type:SymbolType.Variable)
        }
        
        let decors = nodes.map { $0.buildDescription(decorate) }
        
        guard let quartuple = self.symbolQuadruple else {
            // If the symbol is not defined in the global symbol table,
            // i.e. a function or predicate symbol
            let decor = decorate(symbol:self.symbol,type:SymbolType.Function)
            
            // we assume prefix notation for (constant) functions or predicates:
            switch nodes.count {
            case 0:
                return "\(decor)" // constant (or proposition)
            default:
                return "\(decor)(\(decors.joinWithSeparator(separator)))" // prefix function (or predicate)
            }
        }
        
        assert(quartuple.arities.contains(nodes.count), "'\(self.symbolDebugString)' has invalid number \(nodes.count).")
        
        let decor = decorate(symbol:self.symbol, type:quartuple.type)
        
        switch quartuple {
            
        case (.Universal,_,.TptpSpecific,_), (.Existential,_,.TptpSpecific,_):
            return "(\(decor)[\(decors.first!)]:(\(decors.last!)))" // e.g.: ! [X,Y,Z] : ( P(f(X,Y),Z) & f(X,X)=g(X) )
            
        case (_,_,.TptpSpecific,_):
            assertionFailure("\(self.symbolDebugString)' has ambiguous notation.")
            return "\(decor)☇(\(decors.joinWithSeparator(",")))"
            
        case (.Universal,_,_,_), (.Existential,_,_,_):
            return "(\(decor)\(decors.first!) (\(decors.last!)))" // e.g.: ∀ x,y,z : ( P(f(x,y),z) ∧ f(x,x)=g(x) )
            
        case (_,_,.Prefix,_) where nodes.count == 0:
            return "\(decor)"
            
        case (_,_,.Prefix,_):
            return "\(decor)(\(decors.joinWithSeparator(separator)))"
            
        case (_,_,.Minus,_) where nodes.count == 1:
            return "\(decor)(\(decors.first!)"
            
        case (_,_,.Minus,_), (_,_,.Infix,_):
            return decors.joinWithSeparator(decor)
            
        case (_,_,.Postfix,_):
            assertionFailure("'\(symbolDebugString),\(decor)' uses unsupported postfix notation.")
            return "(\(decors.joinWithSeparator(separator)))\(decor)"
            
        case (_,_,.Invalid,_):
            assertionFailure("'\(symbolDebugString),\(decor)' has invalid notation.")
            return "☇\(decor)☇(\(decors.joinWithSeparator(separator)))"
            
        default:
            assertionFailure("'\(symbolDebugString)' has impossible notation.")
            return "☇☇\(decor)☇☇(\(decors.joinWithSeparator(separator)))"
        }
    }
}
