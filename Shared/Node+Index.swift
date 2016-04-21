//
//  Node+Index.swift
//  NyTerms
//
//  Created by Alexander Maringele on 21.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

class SymbolTable {
    convenience init() {
        self.init(arityBits: 4)
    }
    
    init(arityBits : Int) {
        self.maxArity = 1 << arityBits
    }
    
    let maxArity : Int
    var counter : Int = 0
    var table = [String:Int]()
    
    func encode(counter:Int, arity:Int) -> Int {
        return (counter * maxArity) + arity
    }
    
    func decode(code:Int) -> (Int, Int) {
        return (code % maxArity, code % maxArity)
    }
    
    func retrieve(symbol:String, arity:Int) -> Int {
        assert (arity < maxArity, "arity too big: \(arity) ≥ \(maxArity).")
        assert (counter < (Int.max / maxArity))
        
        
        guard let code = table[symbol] else {
            counter += 1
            let code = encode(counter, arity:arity)
            
            table[symbol] = code
            
            return code
        }
        
        assert( decode(code).1 == arity , "\(symbol) \(arity)")
        return code
    }
}

extension Node where Symbol == String {
    
    
    func paths(symbolTable:SymbolTable) -> [[Int]] {
        // variable
        guard let nodes = self.nodes else {
            return [[0]]
        }
        
        
        let code = symbolTable.retrieve(self.symbol, arity: nodes.count)
        
        // constant
        guard nodes.count > 0 else {
            return [[code]]
        }
        
        var paths = [[Int]]()
        
        // function
        for (index,node) in nodes.enumerate() {
            for path in node.paths(symbolTable) {
                paths.append([code,index] + path)
            }
            
        }
        
        return paths
        
    }
}
