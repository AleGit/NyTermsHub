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
}

extension Node where Symbol == String {

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
    
    var description : String {
        return tptpDescription
    }
}

// MARK: Conversion from `Node<Symbol>` to  `Node<String>` implemenations.

extension Node where Symbol == String {
    init<N:Node>(_ s:N) {
        if let nodes = s.nodes {
            self = Self(symbol: N.string(s.symbol), nodes: nodes.map { Self($0) })
        }
        else {
            self = Self(variable:N.string(s.symbol))
        }
    }
}


