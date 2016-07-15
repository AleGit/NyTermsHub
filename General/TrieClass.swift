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

extension TrieClass : CustomStringConvertible {
    var description: String {
        
        return collectPathValues().map {
            (a,b) in
            let ad = a.map { "\($0)" }
            return "\(ad.joined(separator: ".")) \(b)"
        }.joined(separator: "\n")
        
        
        
    }
    
    func collectPathValues() -> [([Key], Set<Value>)] {
        var array = self.valueStore.isEmpty ? [([Key], Set<Value>)]() : [([Key](), self.valueStore)]
        
        for (key,trie) in trieStore {
            for (path,values) in trie.collectPathValues() {
                let pair = ([key] + path, values)
                array.append(pair)
            }
        }
        
        return array
    }
}

extension TrieClass : TrieType {
    
    func insert(_ value: Value) {
        valueStore.insert(value)
    }
    
    func delete(_ value: Value) -> Value? {
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
            collected.formUnion(trie.payload)
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
