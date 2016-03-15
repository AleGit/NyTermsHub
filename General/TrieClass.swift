//
//  TrieClass.swift
//  NyTerms
//
//  Created by Alexander Maringele on 22.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

final class TrieClass<Key: Hashable, Value: Hashable> {
    private var trieStore = [Key: TrieClass<Key, Value>]()
    private var valueStore = Set<Value>()
    
    init() {    }
}

extension TrieClass : TrieType {
    
    func insert(value: Value) {
        valueStore.insert(value)
    }
    
    func delete(value: Value) -> Value? {
        return valueStore.remove(value)
    }
    
    subscript(key:Key) -> TrieClass? {
        get { return trieStore[key] }
        set { trieStore[key] = newValue }
    }
    
    var values : [Value]? {
        return Array(valueStore)
    }
}

extension TrieClass {
    /// get valueStore of `self` and all its successors
    var payload : Set<Value> {
        var collected = valueStore
        for (_,trie) in trieStore {
            collected.unionInPlace(trie.payload)
        }
        return collected
    }
}

extension TrieClass : Equatable {
    var isEmpty: Bool {
        return trieStore.reduce(valueStore.isEmpty) { $0 && $1.1.isEmpty }
    }
    
}

func ==<K,V>(lhs:TrieClass<K,V>, rhs:TrieClass<K,V>) -> Bool {
    if lhs.valueStore == rhs.valueStore && lhs.trieStore == rhs.trieStore {
        return true
    }
    else {
        return false
    }
}

extension TrieClass {
    var tries : [TrieClass] {
        let ts = trieStore.values
        return Array(ts)
    }
}
