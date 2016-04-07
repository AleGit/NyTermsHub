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
        return { self.symbol }
    }
    
    var symbolQuadruple : () -> SymbolQuadruple? {
        return { Self.quadruple(self.symbol) }
    }
    
    static func quadruple(symbol:Symbol) -> SymbolQuadruple? {
        
        switch symbol {
            
        case "" : return  (type:SymbolType.Invalid,category:SymbolCategory.Invalid, notation:SymbolNotation.Invalid, arities: 0..<0)
        case "(" : return  (type:SymbolType.LeftParenthesis,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arities: 0..<0)
        case ")" : return  (type:SymbolType.RightParenthesis,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arities: 0..<0)
        case "⟨" : return  (type:SymbolType.LeftAngleBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arities: 0..<0)
        case "⟩" : return  (type:SymbolType.RightAngleBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arities: 0..<0)
        case "{" : return  (type:SymbolType.LeftCurlyBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arities: 0..<0)
        case "}" : return  (type:SymbolType.RightCurlyBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arities: 0..<0)
        case "[" : return  (type:SymbolType.LeftSquareBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arities: 0..<0)
        case "]" : return  (type:SymbolType.RightSquareBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arities: 0..<0)
            
        // + − × ÷ (mathematical symbols)
        case "+" : return  (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: 1..<Int.max)      //  X, X+Y, X+...+Z
        case "−" : return  (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Minus, arities: 1...2)            // -X, X-Y
        case "×" : return  (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: 1..<Int.max)      // X, X*Y, X*...*X
        case "÷" : return  (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: 2...2)
            
        // - (keyboard symbol)
        case "-" : return  (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Minus, arities: 1...2)          // -X, X-Y
            
        case "=" : return  (type:SymbolType.Equation,category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arities: 2...2)
            
            // tptp symbols
            
        // ⟨assoc_connective⟩ ::= ⟨vline⟩ | &
        case "&" : return  (type:SymbolType.Conjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:0..<Int.max)  // true; A; A & B; A & ... & Z
        case "|" : return  (type:SymbolType.Disjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:0..<Int.max)  // false; A; A | B; A | ... & Z
        // ⟨unary_connective⟩ ::= ~
        case "~" : return  (type:SymbolType.Negation, category:SymbolCategory.Connective, notation:SymbolNotation.Prefix, arities:1...1)          // ~A
        // ⟨binary_connective⟩  ::= <=> | => | <= | <~> | ~<vline> | ~&
        case "=>" : return  (type:SymbolType.Implication, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2)       // A => B
        case "<=" : return  (type:SymbolType.Converse, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2)          // A <= B
        case "<=>" : return  (type:SymbolType.IFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2)              // A <=> B
        case "~&" : return  (type:SymbolType.NAND, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2)              // A ~& B
        case "~|" : return  (type:SymbolType.NOR, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2)               // A ~| B
        case "<~>" : return  (type:SymbolType.NIFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2)             // A <~> B
        // ⟨fol_quantifier⟩ ::= ! | ?
        case "!" : return  (type:SymbolType.Existential, category:SymbolCategory.Connective, notation:SymbolNotation.TptpSpecific, arities:2...2)     // ! [X] : return A
        case "?" : return  (type:SymbolType.Universal, category:SymbolCategory.Connective, notation:SymbolNotation.TptpSpecific, arities:2...2)       // ? [X] : return A
        // ⟨gentzen_arrow⟩      ::= -->
        case "-->" : return  (type:SymbolType.Sequent, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2)          // A --> B
            // ⟨defined_infix_formula⟩  ::= ⟨term⟩ ⟨defined_infix_pred⟩ ⟨term⟩
            // ⟨defined_infix_pred⟩ ::= ⟨infix_equality⟩
            // ⟨infix_equality⟩     ::= =
            //         case "=" : return  (type:SymbolType.Equation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arities:2...2),        // s = t
            // ⟨fol_infix_unary⟩    ::= ⟨term⟩ ⟨infix_inequality⟩ ⟨term⟩
        // ⟨infix_inequality⟩   ::= !=
        case "!=" : return  (type:SymbolType.Inequation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arities:2...2)        // s != t
            
        case "," : return  (type:SymbolType.Tuple, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:(1..<Int.max)) // s; s,t; ...
        default: return nil
        }
    }
}

extension Node where Symbol == String {
    
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


