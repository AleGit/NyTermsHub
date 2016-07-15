//
//  Node(String).swift
//  NyTerms
//
//  Created by Alexander Maringele on 16.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Node where Symbol == String {
    
    var symbolString : () -> String {
        return {
            self.symbol
        }
    }
    
    var symbolQuadruple : () -> SymbolQuadruple? {
        return {
            Self.quadruple(self.symbol)
        }
    }
    
    static func quadruple(_ symbol:Symbol) -> SymbolQuadruple? {
        return defaultQuadruple(symbol)
    }
    
    static func defaultQuadruple(_ symbol:Symbol) -> SymbolQuadruple? {
    
        switch symbol {
            
        case "" : return  (type:SymbolType.invalid,category:SymbolCategory.invalid, notation:SymbolNotation.invalid, arity: .none)
        case "(" : return  (type:SymbolType.leftParenthesis,category:SymbolCategory.auxiliary, notation:SymbolNotation.prefix, arity: .none)
        case ")" : return  (type:SymbolType.rightParenthesis,category:SymbolCategory.auxiliary, notation:SymbolNotation.postfix, arity: .none)
        case "⟨" : return  (type:SymbolType.leftAngleBracket,category:SymbolCategory.auxiliary, notation:SymbolNotation.prefix, arity: .none)
        case "⟩" : return  (type:SymbolType.rightAngleBracket,category:SymbolCategory.auxiliary, notation:SymbolNotation.postfix, arity: .none)
        case "{" : return  (type:SymbolType.leftCurlyBracket,category:SymbolCategory.auxiliary, notation:SymbolNotation.prefix, arity: .none)
        case "}" : return  (type:SymbolType.rightCurlyBracket,category:SymbolCategory.auxiliary, notation:SymbolNotation.postfix, arity: .none)
        case "[" : return  (type:SymbolType.leftSquareBracket,category:SymbolCategory.auxiliary, notation:SymbolNotation.prefix, arity: .none)
        case "]" : return  (type:SymbolType.rightSquareBracket,category:SymbolCategory.auxiliary, notation:SymbolNotation.postfix, arity: .none)
            
        // + − × ÷ (mathematical symbols)
        case "+" : return  (type:SymbolType.function,category:SymbolCategory.functor, notation:SymbolNotation.infix, arity: .variadic(1..<Int.max))      //  X, X+Y, X+...+Z
        case "−" : return  (type:SymbolType.function,category:SymbolCategory.functor, notation:SymbolNotation.minus, arity: .variadic(1...2))            // -X, X-Y
        case "×" : return  (type:SymbolType.function,category:SymbolCategory.functor, notation:SymbolNotation.infix, arity: .variadic(1..<Int.max))      // X, X*Y, X*...*X
        case "÷" : return  (type:SymbolType.function,category:SymbolCategory.functor, notation:SymbolNotation.infix, arity: .fixed(2))
            
        // - (keyboard symbol)
        case "-" : return  (type:SymbolType.function,category:SymbolCategory.functor, notation:SymbolNotation.minus, arity: .variadic(1...2))          // -X, X-Y
            
        case "=" : return  (type:SymbolType.equation,category:SymbolCategory.equational, notation:SymbolNotation.infix, arity: .fixed(2))
            
            // tptp symbols
            
        // ⟨assoc_connective⟩ ::= ⟨vline⟩ | &
        case "&" : return  (type:SymbolType.conjunction, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:.variadic(0..<Int.max))  // true; A; A & B; A & ... & Z
        case "|" : return  (type:SymbolType.disjunction, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:.variadic(0..<Int.max))  // false; A; A | B; A | ... & Z
        // ⟨unary_connective⟩ ::= ~
        case "~" : return  (type:SymbolType.negation, category:SymbolCategory.connective, notation:SymbolNotation.prefix, arity:.fixed(1))          // ~A
        // ⟨binary_connective⟩  ::= <=> | => | <= | <~> | ~<vline> | ~&
        case "=>" : return  (type:SymbolType.implication, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:.fixed(2))       // A => B
        case "<=" : return  (type:SymbolType.converse, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:.fixed(2))          // A <= B
        case "<=>" : return  (type:SymbolType.iff, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:.fixed(2))              // A <=> B
        case "~&" : return  (type:SymbolType.nand, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:.fixed(2))              // A ~& B
        case "~|" : return  (type:SymbolType.nor, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:.fixed(2))               // A ~| B
        case "<~>" : return  (type:SymbolType.niff, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:.fixed(2))             // A <~> B
        // ⟨fol_quantifier⟩ ::= ! | ?
        case "!" : return  (type:SymbolType.existential, category:SymbolCategory.connective, notation:SymbolNotation.tptpSpecific, arity:.fixed(2))     // ! [X] : return A
        case "?" : return  (type:SymbolType.universal, category:SymbolCategory.connective, notation:SymbolNotation.tptpSpecific, arity:.fixed(2))       // ? [X] : return A
        // ⟨gentzen_arrow⟩      ::= -->
        case "-->" : return  (type:SymbolType.sequent, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:.fixed(2))          // A --> B
            // ⟨defined_infix_formula⟩  ::= ⟨term⟩ ⟨defined_infix_pred⟩ ⟨term⟩
            // ⟨defined_infix_pred⟩ ::= ⟨infix_equality⟩
            // ⟨infix_equality⟩     ::= =
            //         case "=" : return  (type:SymbolType.Equation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arity:.Fixed(2)),        // s = t
            // ⟨fol_infix_unary⟩    ::= ⟨term⟩ ⟨infix_inequality⟩ ⟨term⟩
        // ⟨infix_inequality⟩   ::= !=
        case "!=" : return  (type:SymbolType.inequation, category:SymbolCategory.equational, notation:SymbolNotation.infix, arity:.fixed(2))        // s != t
            
        case "," : return  (type:SymbolType.tuple, category:SymbolCategory.connective, notation:SymbolNotation.infix, arity:(.variadic(1..<Int.max))) // s; s,t; ...
        default: return nil
        }
    }
}

extension Node where Symbol == String {
    
    static func symbol(_ type:SymbolType) -> Symbol {
        switch type {
            
        case .equation:
            return "="
            
        case .inequation:
            return "!="
            
        case .negation:
            return "~"
            
        case .wildcard:
            return "*"
            
        default:
            assert(false,"Symbol for \(type) undefined.")
            return "n/a"
        }
    }
    
    static var connectives : [Symbol] {
        return [ "&", "|", "~", "=>", "<=", "<=>", "~&", "~|", "<~>", "!", "?", "-->"]
    }
}



// MARK: CustomStringConvertible

extension Node where Symbol == String {
    
    /// Representation of self:Node in TPTP Syntax.
    var tptpDescription : String {
        return buildDescription { $0.0 }
    }
    
    var description : String {
        return tptpDescription
    }
}

// MARK: Conversion from `Node<Symbol>` to  `Node<String>` implemenations.

extension Node where Symbol == String {
    init<N:Node>(_ s:N) {
        if let nodes = s.nodes {
            self = Self(symbol: s.symbolString(), nodes: nodes.map { Self($0) })
        }
        else {
            self = Self(variable: s.symbolString())
        }
    }
}

extension Node where Symbol == String {
    var preorderString : String {
        guard let nodes = self.nodes else {
            // a variable
            return Self.symbol(.wildcard)
        }
        
        let prefix = self.symbolString()
        return nodes.map { $0.preorderString }.reduce(prefix) { $0 + $1 }
     }
}

extension Node where Symbol == String {
    func normalize<C:CustomStringConvertible>(_ suffix:C) -> Self {
        var varnames = [String:String]()
        return self.normalize(&varnames, prefix:"Z", suffix:suffix)
        
    }
    
    
    private func normalize<B:CustomStringConvertible, C:CustomStringConvertible>(_ varnames : inout [String:String], prefix:B, suffix:C) -> Self {
        guard let nodes = self.nodes else {
            guard varnames.count > 0 else {
                let varname = varnames[self.symbol] ?? "\(prefix)_\(suffix)"
                varnames[self.symbol] = varname
                return Self(variable:varname)
            }
            
            let varname = varnames[self.symbol] ?? "\(prefix)\(varnames.count)_\(suffix)"
            if varnames[self.symbol] == nil { varnames[self.symbol] = varname }
            return Self(variable:varname)
        }
        return Self(symbol:self.symbol, nodes: nodes.map { $0.normalize(&varnames, prefix:prefix, suffix:suffix) })
        
    }
}


