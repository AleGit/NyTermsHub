//
//  Node(Int).swift
//  NyTerms
//
//  Created by Alexander Maringele on 24.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Node where Symbol == Int {
    
    /// startIndex and endIndex are mapped to a single `UInt16`.
    /// Hence only ranges `i...(i+j)` where `i` and `j` are in `0...254` or
    /// i..<Int.max)are supported.
    private func encode(arities range:Range<Int>) -> UInt16 {
        assert(range.startIndex <= Int(UInt8.max))
        
        let size = min(range.endIndex - range.startIndex, Int(UInt8.max))
        
        return UInt16( range.startIndex * 256 + size )
    }
    
    /// The UInt16 value is interpreted as pair of two UInt16 values:
    ///
    /// `(start, size) -> start...(start+size)`
    ///
    /// *examples*:
    ///
    ///     start    size
    ///     00000000 00000000  [0,1) 0-ary (constants)
    ///     00000001 00000000  [1,2) unary
    ///     00000010 00000000  [2,3) binary
    ///     ........ 00000000  [start,start+1) n-ary
    ///     11111111 00000000  [255,256)
    ///     00000000 00000001  [0,2)
    ///     ........ 00000001  [start,start+1]
    ///     ........ ........  [start,start+size+1]
    ///     ........ 11111110  [start,start+254+1)
    ///     ........ 11111111  [start,∞)      start..<Int.max
    private func decode(ariities code:UInt16) -> Range<Int> {
        
        let start = Int(code / 256)
        let size = Int(code % 256)
        let end = size < 255 ? (size+1) : Int.max
        
        return start..<end
        
        /*
         
         
         */
    }
    
}
