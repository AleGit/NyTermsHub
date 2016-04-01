//
//  Node(Int).swift
//  NyTerms
//
//  Created by Alexander Maringele on 24.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

/* Encoding of symbols in UInt (at least UInt64)
 
 variables
                  lookup
 0x  00 00 00 00  00 00 00 00       variable #0 (placeholder variable)
 0x  00 00 00 00  00 00 00 01       variable #1
 0x  00 00 00 00  .. .. .. ..
 0x  00 00 00 00  FF FF FF FF       variable #4.294.967.295
 
 predefined symbols/arities/notation
 
 0x  00 00 00 01  00 00 00 00     invalid
 0x  00 00 00 01  00 00 00 01     negation (unary)
 0x  00 00 00 01  00 00 00 02     disjunction (variadic 0-n, associative)
 0x  00 00 00 01  00 00 00 03     conjunction (variadic 0-n, associative)
 0x  00 00 00 01  00 00 00 04     implication (binary)
 0x  00 00 00 01  00 00 00 05     converse (binary)
 0x  00 00 00 01  00 00 00 06     iff (binary)
 0x  00 00 00 01  00 00 00 07     niff (binary)
 0x  00 00 00 01  00 00 00 08     nor (binary)
 0x  00 00 00 01  00 00 00 09     nand (binary)
 0x  00 00 00 01  00 00 00 0a     sequent (binary)
 0x  00 00 00 01  00 00 00 0b     universal (binary)
 0x  00 00 00 01  00 00 00 0c     existential (binary)
 0x  00 00 00 01  00 00 00 0d     equation (binary)
 0x  00 00 00 01  00 00 00 0e     inequation (binary)
 
 symbols with non-variadic arities and pre-order notation
 (4.294.967.294 different symbols are possible)
 
 T ... type:        4 bit 0..<15        predicate, function, n/a
 R ... reserverd:   12 bit 0..<4.095    for future use
 A ... arity:       2 byte 0..<65.535
 
 0x  00 00 00 02  TR RR AA AA
 0x  ff ff ff ff
 
 
 
 
 
 
 */

import Foundation

let nameMask : UInt     = 0b11111111_11111111_11111111_11111111_00000000_00000000_00000000_00000000 // 32 bit: 4.294.967.296
let variableMask : UInt = 0b00000000_00000000_00000000_00000000_11111111_11111111_11111111_11111111 // 32 bit: 4.294.967.296

let typeMask : UInt     = 0b00000000_00000000_00000000_00000000_11111000_00000000_00000000_00000000 //  5 bit: 32
let categoryMask : UInt = 0b00000000_00000000_00000000_00000000_00000111_00000000_00000000_00000000 //  3 bit: 8
let notationMask : UInt = 0b00000000_00000000_00000000_00000000_00000000_11110000_00000000_00000000 //  4 bit: 16
let arityMask : UInt    = 0b00000000_00000000_00000000_00000000_00000000_00001111_11111111_11111111 // 20 bit: [0..<1024,start+0..<1024]

extension Node where Symbol == Int {

    
    
}

extension Node where Symbol == Int {
    
    
    /// `range.startIndex` and `range.endIndex` are mapped to a single `UInt16`.
    /// Hence only ranges with startIndex in `0...255` are supported:
    /// * `startIndex...(startIndex+size)` where `size ∈ 0..<255` or
    /// * `startIndex..<Int.max` are supported.
    private func encode(arities range:Range<Int>) -> UInt16 {
        assert(range.startIndex <= Int(UInt8.max))
        
        let distance = min(range.endIndex - range.startIndex, Int(UInt8.max))
        
        return UInt16( range.startIndex * 256 + distance )
    }
    
    /// The UInt16 value is interpreted as pair of two UInt16 values:
    ///
    /// `(start, size) -> start...(start+size)`
    ///
    /// *examples*:
    ///
    ///     start    distance
    ///     00000000 00000000  [0,0] 0-ary (constants)
    ///     00000001 00000000  [1,1] unary, e.g. negation
    ///     00000010 00000000  [2,2] binary, e.g. equality
    ///     ........ 00000000  [start,start] n-ary
    ///     11111111 00000000  [255,255]
    ///     00000001 00000001  [1,2] e.g. 1+(-2) vs. 1-2
    ///     00000000 00000001  [0,2)
    ///     ........ 00000001  [start,start+1]
    ///     ........ ........  [start,start+distance]
    ///     ........ 11111110  [start,start+254]
    ///     ........ 11111111  [start,∞)      start..<Int.max
    private func decode(ariities code:UInt16) -> Range<Int> {
        
        let start = Int(code / 256)
        let size = Int(code % 256)
        
        if size < 255 {
            return start...(start+size)
        }
        else {
            return start..<Int.max
            
        }
        
        /*
         
         
         */
    }
    
}
