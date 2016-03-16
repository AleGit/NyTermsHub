//
//  Node+Indication.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

// MARK: helpers

func +(lhs:(Int,Int,Int),rhs:(Int,Int,Int)) -> (Int,Int,Int) {
    return (lhs.0+rhs.0, lhs.1+rhs.1, lhs.2+rhs.2)
}

// MARK: -

extension Node {
    var height : Int {
        guard let nodes = self.nodes
            where nodes.count > 0 // superfluous but correct
            else  {
                // constants and variables have height = 0
                return 0
        }
        
        // the height of a (constant) function
        // is one plus the maximum height of its arguments
        return 1 + nodes.reduce(0) { max($0,$1.height) }
    }
    
    var size : Int {
        guard let nodes = self.nodes
            where nodes.count > 0 // superfluous but correct
            else  {
                // constants and variables have size = 1
                return 1
        }
        
        // the size of a (constant) function
        // is one plus the sum of sizes of its arguments.
        return nodes.reduce(1) { $0+$1.size }
        // 1 + nodes.reduce(0) { $0+$1.size }
    }
    
    var width : Int {
        guard let nodes = self.nodes
            where nodes.count > 0 // necessary
            else {
                // constants and variables have width = 1
                return 1
        }
        
        // the width of a function
        // is the sum of the widths of its arguments
        return nodes.reduce(0) { $0 + $1.width }
    }
}

// MARK: -


typealias SymbolIndications = (type:SymbolType,arities:Set<Int>,occurences:Int)
typealias NodeDimensions = (height:Int, size:Int, width:Int, indications:[StringSymbol:SymbolIndications])

extension Node where Symbol == String {
    /// Start at predicate node (atom) or above (negative literal, clause, formula)
    func dimensions() -> NodeDimensions {
        let belowPredicate = false // we assume that we start above or at predicates
        var indications = [Symbol:SymbolIndications]()
        
        let (height,size,width) = self.dimensions(belowPredicate, symbols: &indications)
        return (height,size,width,indications)
    }
    
    private func dimensions(
        belowPredicate:Bool,
        inout symbols:[Symbol:SymbolIndications]
        
        ) -> (height:Int, size:Int, width:Int) {
            let key = self.symbol
            
            guard let nodes = self.nodes else {
                assert(key.quadruple == nil) // variables must not be predefined
                assert(belowPredicate)
                
                var value = symbols[key] ?? (SymbolType.Variable,Set<Int>(),0)
                
                assert(value.type == .Variable)
                assert(value.arities.isEmpty)
                
                value.occurences += 1
                
                symbols[key] = value
                
                return (height:0,size:1,width:1)
            }
            
            // types of symbols above predicate must be predefined
            let type = key.type ?? (belowPredicate ? SymbolType.Function : SymbolType.Predicate)

            // did the symbol appear befoe?, if not create an entry for function and predicate symbols with derived arity
            var value = symbols[key] ?? (type,Set(arrayLiteral: nodes.count),0)
            
            assert(value.type == type,"\(key) can't be used as \(value.type) and \(type)")
            // predefined arities (range) or derived arity (set of one) must match
            assert((
                key.arities?.contains(nodes.count) ?? false) // either the arity of a symbol is predefined and potentially variadic (e.g. disjunction)
                || value.arities.contains(nodes.count), // or defined at runtime with the first encounter (e.g. predicate and function symbols)
                (key.arities != nil ?
                    "Predefined arities \(key.arities!) does not contain" :
                    "Runtime arities \(value.arities) does not contain variadic" )
                + " arity \(nodes.count) for symbol \(key)."
            )
            
            value.arities.insert(nodes.count)
            value.occurences += 1
            
            symbols[key] = value
            
            let height = nodes.count == 0 ? 0 : 1       // the height of a leaf is 0
            let size = 1                                // the size of a leaf is 1
            let width = 1 - height                      // the width of a leaf is 1
            
            // the height of an inner node is 1 + the maximum of heights of its children.
            // the size of an inner node is 1 + the sum of sizes of its children.
            // the width of an inner node is 0 + the sum of widths of its children.
            
            return (height,size,width) + nodes.reduce((height:0,size:0,width:0)) {
                (a,b) -> (height:Int,size:Int,width:Int) in
                let (h0,s0,w0) = a
                let (h1,s1,w1) = b.dimensions(
                    belowPredicate || (type.isPredicational),
                    symbols: &symbols)
                
                return ( max(h0,h1), s0+s1, w0+w1 )
            }
    }
}
