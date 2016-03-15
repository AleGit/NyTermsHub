//
//  NodeX.swift
//  NyTerms
//
//  Created by Alexander Maringele on 15.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

typealias SymbolQuintuple = (string:String, type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arities:Range<Int>)

protocol NodeX : Hashable, CustomStringConvertible, StringLiteralConvertible {
    typealias SymbolX : Hashable
    
    static func symbolQuadruple(symbol:SymbolX) -> SymbolQuintuple?
    
    var symbol : SymbolX { get }
    var nodes : [Self]? { get }
    
    init (symbol:SymbolX, nodes:[Self]?)
}

extension NodeX where SymbolX == String {
    static func symbolQuadruple(symbol:SymbolX) -> SymbolQuintuple? {
        guard let (type,category,notation,arities) = symbol.quadruple else { return nil }
        return (symbol,type,category,notation,arities)
    }
}

