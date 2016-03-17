//
//  Node(String).swift
//  NyTerms
//
//  Created by Alexander Maringele on 16.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

// MARK: Node(String)

extension Node where Symbol == String {
    static func quadruple(symbol:Symbol) -> SymbolQuadruple? {
        
        return symbol.quadruple
    }
    
    static func string(symbol:Symbol) -> String {
        return symbol
    }
    
    static func symbol(type:SymbolType) -> Symbol {
        switch type {
            
        case .Equation:
            return "="
            
        case .Wildcard:
            return "*"
            
        default:
            assert(false,"Symbol for \(type) undefined.")
            return "n/a"
        }
    }
}

// MARK: CustomStringConvertible

extension Node where Symbol == String {
    
    
    /// Representation of self:Node in TPTP Syntax.
    var tptpDescription : String {
        return buildDescription { $0.0 }
    }
    
    func buildDescription(decorate:(symbol:String,type:SymbolType)->String) -> String {
        
        assert(!self.symbol.isEmpty, "a term must not have an emtpy symbol")
        
        guard let nodes = self.nodes else {
            // since self has not list of subnodes at all,
            // self must be a variable term
            assert((self.symbol.type ?? SymbolType.Variable) == SymbolType.Variable, "\(self.symbol) is variable term with wrong type \(self.symbol.quadruple!)")
            
            return decorate(symbol:self.symbol, type:SymbolType.Variable)
        }
        
        let decors = nodes.map { $0.buildDescription(decorate) }
        
        guard let quadruple = self.symbol.quadruple else {
            // If the symbol is not defined in the global symbol table,
            // i.e. a function or predicate symbol
            let decor = decorate(symbol:self.symbol,type:SymbolType.Function)
            
            // we assume prefix notation for (constant) functions or predicates:
            switch nodes.count {
            case 0:
                return "\(decor)" // constant (or proposition)
            default:
                
                return "\(decor)(\(decors.joinWithSeparator(Symbol.separator)))" // prefix function (or predicate)
            }
        }
        
        assert(quadruple.arities.contains(nodes.count), "'\(self.symbol)' has invalid number \(nodes.count) of subnodes  ∉ \(quadruple.arities).")
        
        let decor = decorate(symbol:self.symbol, type:quadruple.type)
        
        switch quadruple {
            
        case (.Universal,_,.TptpSpecific,_), (.Existential,_,.TptpSpecific,_):
            return "(\(decor)[\(decors.first!)]:(\(decors.last!)))" // e.g.: ! [X,Y,Z] : ( P(f(X,Y),Z) & f(X,X)=g(X) )
            
        case (_,_,.TptpSpecific,_):
            assertionFailure("'\(symbol)' has ambiguous notation \(quadruple).")
            return "\(decor)☇(\(decors.joinWithSeparator(Symbol.separator)))"
            
        case (.Universal,_,_,_), (.Existential,_,_,_):
            return "(\(decor)\(decors.first!) (\(decors.last!)))" // e.g.: ∀ x,y,z : ( P(f(x,y),z) ∧ f(x,x)=g(x) )
            
        case (_,_,.Prefix,_) where nodes.count == 0:
            return "\(decor)"
            
        case (_,_,.Prefix,_):
            return "\(decor)(\(decors.joinWithSeparator(Symbol.separator)))"
            
        case (_,_,.Minus,_) where nodes.count == 1:
            return "\(decor)(\(decors.first!)"
            
        case (_,_,.Minus,_), (_,_,.Infix,_):
            return decors.joinWithSeparator(decor)
            
        case (_,_,.Postfix,_):
            assertionFailure("'\(symbol),\(decor)' uses unsupported postfix notation \(quadruple).")
            return "(\(decors.joinWithSeparator(Symbol.separator)))\(decor)"
            
        case (_,_,.Invalid,_):
            assertionFailure("'\(symbol),\(decor)' has invalid notation: \(quadruple)")
            return "☇\(decor)☇(\(decors.joinWithSeparator(Symbol.separator)))"
            
        default:
            assertionFailure("'\(symbol)' has impossible notation: \(quadruple)")
            return "☇☇\(decor)☇☇(\(decors.joinWithSeparator(Symbol.separator)))"
        }
    }
    
    var description : String {
        return tptpDescription
    }
}

extension Node where Symbol == String {
    
    var laTeXDescription : String {
        return buildDescription ( LaTeX.Symbols.decorate )
        
    }
}

extension Node where Symbol == String {
    private func buildSyntaxTree(level:Int, decorate:(symbol:String,type:SymbolType)->String) -> String {
        
        var s = "node "
        
        if let nodes = self.nodes {
            
            
            
            let quadruple = self.symbol.quadruple ??
                (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: 0..<Int.max)
            
            let decor = decorate(symbol:self.symbol,type:quadruple.type)
            
            switch quadruple.type {
            case .Tuple:
                let variables = nodes.map { decorate(symbol: $0.symbol, type: .Variable) }
                s += "{$[\(variables.joinWithSeparator(","))]$}"
            default:
                let trees = nodes.map { "child {\($0.buildSyntaxTree(level+1,decorate: decorate))}" }
                
                
                let n = nodes.count
                
                switch n {
                case 0:
                    s += "{$\(decor)$}" // constant (or proposition)
                default:
                    
                    s += "{$\(decor)$}"
                    
                    var width = 160
                    for _ in 0..<level { width /= 2 }
                    let (start,angle) = (n == 1) ? (-90,0) : (-90-width/2,-width/(n-1))
                    s += "\n% [clockwise from=\(start),sibling angle=\(angle)]"
                    
                    var separator = "\n"
                    for _ in 0..<level { separator += " " }
                    s += separator
                    
                    s += "\(trees.joinWithSeparator(separator))" // prefix function (or predicate)
                }
            }
        }
        else {
            s += "{$\(decorate(symbol:self.symbol, type:SymbolType.Variable))$}"
        }
        
        return s
    }
    
    var tikzSyntaxTree : String {
        let tree = buildSyntaxTree(0, decorate: LaTeX.Symbols.decorate)
        return "\\\(tree);"
    }
}


