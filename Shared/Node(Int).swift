//
//  Node(Int).swift
//  NyTerms
//
//  Created by Alexander Maringele on 24.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Node where Symbol == Int {
//    
//    func decode(typeBits:UInt8 = 5, categoryBits:UInt8 = 3, notationBits:UInt8 = 3, arityBits:UInt8) -> SymbolQuadruple {
//        
//    }
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
