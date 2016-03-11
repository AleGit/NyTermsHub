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

func /(lhs:(Int,Int,Int),rhs:Int) -> (Double,Double,Double) {
    
    let f = { (a:Int,b:Int) -> Double in
        let c = 10.0 * Double(a)/Double(b) + 0.5
        
        return floor(c)/10.0
    }
    
    return (f(lhs.0,rhs), f(lhs.1,rhs), f(lhs.2,rhs))
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
    
    var dimensions : NodeDimensions {
        guard let nodes = self.nodes
            where nodes.count > 0 // superfluous but correct
            else  {
                // constants and variables have height = 0
                return (0,1,1)
        }
        
        // the height of a (constant) function
        // is one plus the maximum height of its arguments
        return (1,1,0) + nodes.reduce((0,0,0)) {
            (a,b) -> (Int,Int,Int) in
            let (h0,s0,w0) = a
            let (h1,s1,w1) = b.dimensions
            
            return ( max(h0,h1), s0+s1, w0+w1 )
            
        }
    }
}

// MARK: -

typealias NodeDimensions = (height:Int, size:Int, width:Int)
typealias NodeIndications = (type:SymbolType,arities:Set<Int>,occurences:Int)

extension Node {
    func dimensions(
        belowPredicate:Bool,
        inout symbols:[Symbol:NodeIndications]
        
        ) -> (height:Int, size:Int, width:Int) {
            let key = self.symbol
            
            guard let nodes = self.nodes else {
                assert(key.quadruple == nil) // variables must not be predefined
                assert(belowPredicate)    // variables must be below predicates
                
                var value = symbols[key] ?? (SymbolType.Variable,Set<Int>(),0)
                
                assert(value.type == .Variable)
                assert(value.arities.isEmpty)
                
                value.occurences += 1
                
                symbols[key] = value
                
                return (height:0,size:1,width:1)
            }
            
            // symbols above predicate must be predefined
            let type = key.type ?? (belowPredicate ? SymbolType.Function : SymbolType.Predicate)

            var value = symbols[key] ?? (type,Set(arrayLiteral: nodes.count),0)
            
            assert(value.type == type)
            // predefined arities (range) or derived arity (set of one) must match
            assert((key.arities?.contains(nodes.count) ?? false) || value.arities.contains(nodes.count))
            
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
                    belowPredicate || (type == SymbolType.Predicate),
                    symbols: &symbols)
                
                return ( max(h0,h1), s0+s1, w0+w1 )
            }
    }
    
}
