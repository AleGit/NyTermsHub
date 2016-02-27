//
//  TrieClass.swift
//  NyTerms
//
//  Created by Alexander Maringele on 22.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

final class TrieClass<K: Hashable, V: Hashable> {
    typealias Key = K
    typealias Value = V
    private (set) var tries = [Key: TrieClass<Key, Value>]()
    private (set) var valueSet = Set<Value>()
    
    init() {    }
}

extension TrieClass : TrieType {
    
    func insert(value: Value) {
        valueSet.insert(value)
    }
    
    func delete(value: Value) -> Value? {
        return valueSet.remove(value)
    }
    
    subscript(key:Key) -> TrieClass? {
        get { return tries[key] }
        set { tries[key] = newValue }
    }
    
    var values : [Value]? {
        return Array(valueSet)
    }
}

extension TrieClass {
    /// get valueSet of `self` and all its successors
    var payload : Set<Value> {
        var collected = valueSet
        for (_,trie) in tries {
            collected.unionInPlace(trie.payload)
        }
        return collected
    }
}

extension TrieClass : Equatable {
    var isEmpty: Bool {
        return tries.reduce(valueSet.isEmpty) { $0 && $1.1.isEmpty }
    }
    
}

func ==<K,V>(lhs:TrieClass<K,V>, rhs:TrieClass<K,V>) -> Bool {
    if lhs.valueSet == rhs.valueSet && lhs.tries == rhs.tries {
        return true
    }
    else {
        return false
    }
}
