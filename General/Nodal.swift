//
//  PowerNode.swift
//  NyTerms
//
//  Created by Alexander Maringele on 07.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

protocol Nodal {
    
    typealias Key : Hashable
    typealias Cargo
    
    var cargo : Cargo { get }
    var count : Int { get }
    subscript(key:Key) -> Self? { get }
    subscript(path:[Key]) -> Self? { get }
}

extension Array where Element:Hashable {
    
}

extension Nodal {
    subscript(path:[Key]) -> Self? {
        get {
            guard let (head,tail) = path.decompose() else { return self }
            return self[head]?[tail]
        }
    }
}

struct NodalArray<C:Equatable> : Nodal {
    var cargo : C
    var subnodals : [NodalArray?]
    
    var count : Int { return subnodals.count }
    
    subscript(key:Int) -> NodalArray? {
        get {
            guard key >= 0 else { return nil }
            guard key < subnodals.count else { return nil }
            return subnodals[key]
        }
    }
    
    
}

struct NodalDictionary<K:Hashable,C> : Nodal {
    var subnodals = [K : NodalDictionary<K,C>]()
    var cargo : C
    
    var count : Int { return subnodals.count }
    
    subscript(key:K) -> NodalDictionary<K,C>? {
        get {
            return subnodals[key]
        }
    }
}

typealias NodalStringTrie = NodalDictionary<Character,String>

typealias NodalTerm = NodalArray<String>

typealias NodalTermPathTrie = NodalDictionary<String,Set<Int>>


