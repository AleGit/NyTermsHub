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
            guard let (head,tail) = path.decompose else { return self }
            return self[head]?[tail]
        }
    }
}

struct NodalArray<C:Equatable> : Nodal {
    var cargo : C
    var nodals : [NodalArray?]
    
    var count : Int { return nodals.count }
    
    subscript(key:Int) -> NodalArray? {
        get {
            guard key >= 0 else { return nil }
            guard key < nodals.count else { return nil }
            return nodals[key]
        }
    }
}

struct NodalDictionary<K:Hashable,C> : Nodal {
    var nodals = [K : NodalDictionary<K,C>]()
    var cargo : C
    
    var count : Int { return nodals.count }
    
    subscript(key:K) -> NodalDictionary<K,C>? {
        get {
            return nodals[key]
        }
    }
}

typealias NodalStringTrie = NodalDictionary<Character,String>

typealias NodalTerm = NodalArray<String>

typealias NodalTermPathTrie = NodalDictionary<String,Set<Int>>


