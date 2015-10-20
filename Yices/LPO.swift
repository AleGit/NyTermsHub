//
//  LPO.swift
//  NyTerms
//
//  Created by Sarah Winkler on 24/09/15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

public struct LPO {
    
    var precedence = [Symbol: term_t]() // precedence variables
    var k :Int? = nil          // counter value for this particular LPO instance
    static var counter = 0 // counter for LPO instances
    
    public mutating func prec(f:Symbol) -> term_t  {
        var p = precedence[f]
        if p == nil {
            let name = "lpo" + String(k!) + f
            p = Yices.newIntVar(name)
            precedence[f] = p
        }
        return p!
    }
    
    public func ge<T:Node>(l:T, r:T) -> term_t  {
        return Yices.bot()
    }
    
}

