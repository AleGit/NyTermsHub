//
//  UnitArrayPair.swift
//  NyTerms
//
//  Created by Alexander Maringele on 25.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

protocol UnitArrayPair : Hashable {
    associatedtype U : Hashable
    associatedtype T : Hashable
    
    var unit : U { get }
    var array : [T] { get }
}

extension UnitArrayPair {
    var hashValue: Int {
        return self.unit.hashValue &+ array.hashValue
    }
}

func ==<UAP:UnitArrayPair>(lhs:UAP, rhs:UAP) -> Bool {
    return lhs.unit == rhs.unit && lhs.array == rhs.array
}