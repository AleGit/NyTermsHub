//
//  TailTrie.swift
//  NyTerms
//
//  Created by Alexander Maringele on 10.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

/// A trie that stores values at leaf nodes and only at leave nodes.
/// Hence paths must not be prefixes of other paths:
///
/// - [1,2] [1,1,1] are valid paths in one trie
/// - [1,2] [1,2,1] are clashing paths in one trie
///
/// This kind of trie is suitable for term path indexing where terms are stored at leaves only.
indirect enum TailTrie<K:Hashable,V:Hashable> {
    typealias Key = K
    typealias Value = V
    case inner(tries:[K:TailTrie])
    case leaf(values:Set<V>)
}

extension TailTrie : TrieType {
    init() { self = TailTrie.inner(tries: [Key:TailTrie<Key,Value>]()) }
    
    mutating func insert(_ value: Value) {
        switch self {
        case .inner(let tries):
            if !tries.isEmpty { assert(false,"path is too short!") }
            self = .leaf(values:Set([value]))
            return
        case .leaf(var values):
            values.insert(value)
            self = .leaf(values:values)
            return
        }
    }
    
    mutating func delete(_ value: Value) -> Value? {
        switch self {
        case .inner:
            return nil
        case .leaf(var values):
            let v = values.remove(value)
            self = .leaf(values:values)
            return v
        }
    }
    
    subscript(key:Key) -> TailTrie? {
        get {
            switch self {
            case .inner(let tries):
                return tries[key]
            case .leaf:
                return nil            }
        }
        
        set {
            
            switch self {
            case .inner(var tries):
                tries[key] = newValue
                self = .inner(tries: tries)
            case .leaf:
                guard let trie = newValue else { return }
                let tries = [key : trie]
                self = .inner(tries: tries)
            }
        }
    }
    
    var values : [Value]? {
        switch self {
        case .inner:
            return nil
        case .leaf(let values):
            return Array(values)
        }
    }
}

extension TailTrie : CustomStringConvertible {
    var description : String {
        switch self {
        case .inner(let tries):
            let strings = tries.map { "\($0):\($1)" }.joined(separator: ",")
            return "[\(strings)]"
        case .leaf(let values):
            return "{\(values.map { "\($0)" }.joined(separator: ","))}"
        }
    }
}

extension TailTrie : Equatable {
    var isEmpty : Bool {
        switch self {
        case .leaf(let values):
            return values.isEmpty
        case .inner(let tries):
            return tries.isEmpty
        }
    }
    
}

func == <K,V>(lhs:TailTrie<K,V>, rhs:TailTrie<K,V>) -> Bool {
    switch(lhs,rhs) {
    case (.inner(let l), .inner(let r)):
        return l == r
    case (.leaf(let l), .leaf(let r)):
        return l == r
    default:
        return false
    }
}

extension TailTrie {
    var tries : [TailTrie] {
        switch self {
        case .leaf:
            return [TailTrie]() //empty
        case .inner(let tries):
            return Array(tries.values)
        }
    }
}
