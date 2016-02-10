//
//  TrieNode.swift
//  NyTerms
//
//  Created by Alexander Maringele on 10.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

indirect enum TrieNode<K:Hashable,V:Hashable> {
    typealias Key = K
    typealias Value = V
    case Inner(tries:[K:TrieNode])
    case Leaf(values:Set<V>)
}

enum TrieNodeError : ErrorType {
    case PathIsTooShort
    case PathIsTooLong
}

extension TrieNode {
    mutating func insert<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) throws {
        guard let (head,tail) = path.decompose else {
            switch self {
            case .Inner(let tries):
                if !tries.isEmpty { throw TrieNodeError.PathIsTooShort }
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
            if !values.isEmpty { throw TrieNodeError.PathIsTooLong }
            var trie = TrieNode.Inner(tries: [K:TrieNode]())
            try trie.insert(tail, value:value)
            self = .Inner(tries: [head:trie])
            
        case .Inner(var tries):
            
            var trie = tries[head] ?? (tail.isEmpty ?
                TrieNode.Leaf(values: Set<V>()) : TrieNode.Inner(tries: [K:TrieNode]()))
            try trie.insert(tail, value: value)
            tries[head] = trie
            self = .Inner(tries: tries)
            
        }
    }
    
    mutating func delete<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) -> Value? {
            guard let (head,tail) = path.decompose else {
                switch self {
                case .Inner:
                    return nil
                case .Leaf(var values):
                    let ele = values.remove(value)
                    self = .Leaf(values:values)
                    return ele
                }
            }
            switch self {
            case .Leaf:
                return nil
                
            case .Inner(var tries):
                guard var trie = tries[head] else { return nil }
                guard let ele = trie.delete(tail, value: value) else { return nil }
                
                tries[head] = trie.isEmpty ? nil : trie
                self = .Inner(tries: tries)
                return ele
            }
    }
    
    
    
//    mutating func insert(path: [K], value: V) throws {
//        guard let (head,tail) = path.decompose else {
//            switch self {
//            case .Inner(let tries):
//                if !tries.isEmpty { throw TrieNodeError.PathIsTooShort }
//                self = .Leaf(values:Set([value]))
//                return
//            case .Leaf(var values):
//                values.insert(value)
//                self = .Leaf(values:values)
//                return
//            }
//        }
//        switch self {
//        case .Leaf(let values):
//            if !values.isEmpty { throw TrieNodeError.PathIsTooLong }
//            var trie = TrieNode.Inner(tries: [K:TrieNode]())
//            try trie.insert(tail, value:value)
//            self = .Inner(tries: [head:trie])
//            
//        case .Inner(var tries):
//            
//            var trie = tries[head] ?? (tail.isEmpty ?
//                TrieNode.Leaf(values: Set<V>()) : TrieNode.Inner(tries: [K:TrieNode]()))
//            try trie.insert(tail, value: value)
//            tries[head] = trie
//            self = .Inner(tries: tries)
//            
//        }
//    }
    
}

extension TrieNode : CustomStringConvertible {
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

extension TrieNode : Equatable {
    var isEmpty : Bool {
        switch self {
        case .Leaf(let values):
            return values.isEmpty
        case .Inner(let tries):
            return tries.isEmpty
        }
    }
    
}

func == <K,V>(lhs:TrieNode<K,V>, rhs:TrieNode<K,V>) -> Bool {
    switch(lhs,rhs) {
    case (.Inner(let l), .Inner(let r)):
        return l == r
    case (.Leaf(let l), .Leaf(let r)):
        return l == r
    default:
        return false
    }
}