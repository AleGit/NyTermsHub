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
    private var tries = [Key: TrieClass<Key, Value>]()
    private (set) var values = Set<Value>()
    
    init() {    }
}

extension TrieClass : TrieType {
    
     func insert<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) {
            guard let (head,tail) = path.decompose else {
                values.insert(value)
                return
            }
            
            let trie = tries[head] ?? TrieClass()
            trie.insert(tail, value: value)
            tries[head] = trie
    }
    
    
    func delete<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) -> Value? {
            guard let (head,tail) = path.decompose else {
                return values.remove(value)
            }
            
            guard let trie = tries[head] else { return nil }
            let v = trie.delete(tail, value:value)
            tries[head] = trie.isEmpty ? nil : trie
            return v
    }
    
    func retrieve<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C) -> [Value]? {
            guard let (head,tail) = path.decompose else {
                return Array(values)
            }
            
            return tries[head]?.retrieve(tail)
    }
}

extension TrieClass {
    
    
    func generate() -> DictionaryGenerator<Key, TrieClass<Key, Value>> {
        let generator = tries.generate()
        return generator
    }
    
    var subtries : [Key: TrieClass<Key, Value>] {
        return tries
    }
    
    /// retrieves subtrie at key path.
    /// if key path does not exist nil will be returned
    subscript(path:[Key]) -> TrieClass? {
        guard let (head,tail) = path.decompose else { return self }
        
        guard let trie = tries[head] else { return nil }
        
        return trie[tail]
    }
    
    subscript(key:Key) -> TrieClass? {
        return tries[key]
    }
    
    
}

extension TrieClass {
    /// get values of `self` and all its successors
    var payload : Set<Value> {
        var collected = values
        for (_,trie) in tries {
            collected.unionInPlace(trie.payload)
        }
        return collected
    }
}

extension TrieClass : Equatable {
    var isEmpty: Bool {
        return tries.reduce(values.isEmpty) { $0 && $1.1.isEmpty }
    }
    
}

func ==<K,V>(lhs:TrieClass<K,V>, rhs:TrieClass<K,V>) -> Bool {
    if lhs.values == rhs.values && lhs.tries == rhs.tries {
        return true
    }
    else {
        return false
    }
}
