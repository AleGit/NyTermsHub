//
//  SymbolTable.swift
//  NyTerms
//
//  Created by Alexander Maringele on 18.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

//protocol SymbolTable : class {
//    associatedtype Symbol:Hashable
//    func register(symbol:Symbol, type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arity:SymbolArity)
//    subscript(symbol:Symbol) -> SymbolQuadruple? { get set }
//    
//}
//
//
//class SymbolTableClass<Symbol:Hashable> : SymbolTable {
//    private var symbols = [Symbol:SymbolQuadruple]()
//    
//    func register(symbol:Symbol, type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arity:SymbolArity) {
//        
//        if let quadruple = symbols[symbol] {
//            assert(quadruple.type==type)
//            assert(quadruple.category == category)
//            assert(quadruple.notation == notation)
//            
//            assert(quadruple.arity.contains(arity),"\(symbol), \(quadruple), \(arity)")
//            
//        }
//        
//        else {
//            symbols[symbol] = (type,category,notation,arity)
//        }
//        
//    }
//    
//    subscript (symbol:Symbol) -> SymbolQuadruple? {
//        get {
//            return symbols[symbol]
//        }
//        set {
//            symbols[symbol] = newValue
//        }
//    }
//    
//    
//}
