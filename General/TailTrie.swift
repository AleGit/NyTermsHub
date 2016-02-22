//
//  TailTrie.swift
//  NyTerms
//
//  Created by Alexander Maringele on 10.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

/// A trie that stores values at leaf nodes and only at leave nodes.
/// Hence symHopPaths must not be prefixes of other symHopPaths:
///
/// - [1,2] [1,1,1] are valid symHopPaths in one trie
/// - [1,2] [1,2,1] are clashing symHopPaths in one trie
///
/// This kind of trie is suitable for term path indexing where terms are stored at leaves only.
indirect enum TailTrie<K:Hashable,V:Hashable> {
    typealias Key = K
    typealias Value = V
    case Inner(tries:[K:TailTrie])
    case Leaf(values:Set<V>)
}

extension TailTrie : TrieType {
    init() { self = TailTrie.Inner(tries: [Key:TailTrie<Key,Value>]()) }
    
    mutating func insert<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C, value:Value) {
        guard let (head,tail) = path.decompose else {
            switch self {
            case .Inner(let tries):
                if !tries.isEmpty { assert(false,"path is too short!") }
                self = .Leaf(values:Set([value]))
                return
            case .Leaf(var values):
                values.insert(value)
                self = .Leaf(values:values)
                return
            }
        }
        switch self {
        case .Leaf(let values):
            if !values.isEmpty { assert(false,"path is too long!") }
            var trie = TailTrie.Inner(tries: [K:TailTrie]())
            trie.insert(tail, value:value)
            self = .Inner(tries: [head:trie])
            
        case .Inner(var tries):
            
            var trie = tries[head] ?? (tail.isEmpty ?
                TailTrie.Leaf(values: Set<V>()) : TailTrie.Inner(tries: [K:TailTrie]()))
            trie.insert(tail, value: value)
            tries[head] = trie
            self = .Inner(tries: tries)
            
        }
    }

    mutating func delete<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C, value:Value) -> Value? {
            guard let (head,tail) = path.decompose else {
                switch self {
                case .Inner:
                    return nil
                case .Leaf(var values):
                    let v = values.remove(value)
                    self = .Leaf(values:values)
                    return v
                }
            }
            switch self {
            case .Leaf:
                return nil
                
            case .Inner(var tries):
                guard var trie = tries[head] else { return nil }
                guard let v = trie.delete(tail, value: value) else { return nil }
                
                tries[head] = trie.isEmpty ? nil : trie
                self = .Inner(tries: tries)
                return v
            }
    }
    
    func retrieve<C:CollectionType where
        C.Generator.Element == Key, C.SubSequence.Generator.Element == Key>(path:C) -> [Value]? {
            guard let (head,tail) = path.decompose else {
                switch self {
                case .Inner:
                    return nil
                case .Leaf(let values):
                    return Array(values)
                }
            }
            
            switch self {
            case .Leaf:
                return nil
            case .Inner(let tries):
                return tries[head]?.retrieve(tail)
            }
            
    }
    
    
}

extension TailTrie : CustomStringConvertible {
    var description : String {
        switch self {
        case .Inner(let tries):
            let strings = tries.map { "\($0):\($1)" }.joinWithSeparator(",")
            return "[\(strings)]"
        case .Leaf(let values):
            return "{\(values.map { "\($0)" }.joinWithSeparator(","))}"
        }
    }
}

extension TailTrie : Equatable {
    var isEmpty : Bool {
        switch self {
        case .Leaf(let values):
            return values.isEmpty
        case .Inner(let tries):
            return tries.isEmpty
        }
    }
    
}

func == <K,V>(lhs:TailTrie<K,V>, rhs:TailTrie<K,V>) -> Bool {
    switch(lhs,rhs) {
    case (.Inner(let l), .Inner(let r)):
        return l == r
    case (.Leaf(let l), .Leaf(let r)):
        return l == r
    default:
        return false
    }
}