import Foundation

/// A trie stores values at paths, i.e. sequences of keys
/// [[wikikpedia]](https://en.wikipedia.org/wiki/TrieStruct)
///
///
struct TrieStruct<K: Hashable, V: Hashable> {
    typealias Key = K
    typealias Value = V
    private var tries = [Key: TrieStruct<Key, Value>]()
    private (set) var values = Set<Value>()
    
//    init<C:CollectionType where C.Generator.Element == Key,
//        C.SubSequence.Generator.Element == Key>(path:C, value:Value) {
//            
//            self.insert(path, value:value)
//    }
    
    init() {    }
}

extension TrieStruct : TrieType {
    
    mutating func insert<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) {
            guard let (head,tail) = path.decompose else {
                values.insert(value)
                return
            }
            
            var trie = tries[head] ?? TrieStruct()
            trie.insert(tail, value: value)
            tries[head] = trie
    }
    
    
    mutating func delete<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) -> Value? {
            guard let (head,tail) = path.decompose else {
                return values.remove(value)
            }
            
            guard var trie = tries[head] else { return nil }
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

extension TrieStruct {
    
    
    func generate() -> DictionaryGenerator<Key, TrieStruct<Key, Value>> {
        let generator = tries.generate()
        return generator
    }
    
    var subtries : [Key: TrieStruct<Key, Value>] {
        return tries
    }
    
    /// retrieves subtrie at key path.
    /// if key path does not exist nil will be returned
    subscript(path:[Key]) -> TrieStruct? {
        guard let (head,tail) = path.decompose else { return self }
        
        guard let trie = tries[head] else { return nil }
        
        return trie[tail]
    }
    
    subscript(key:Key) -> TrieStruct? {
        return tries[key]
    }
    

}

extension TrieStruct {
    /// get values of `self` and all its successors
    var payload : Set<Value> {
        var collected = values
        for (_,trie) in tries {
            collected.unionInPlace(trie.payload)
        }
        return collected
    }
}

extension TrieStruct : Equatable {
    var isEmpty: Bool {
        return tries.reduce(values.isEmpty) { $0 && $1.1.isEmpty }
    }
    
}

func ==<K,V>(lhs:TrieStruct<K,V>, rhs:TrieStruct<K,V>) -> Bool {
    if lhs.values == rhs.values && lhs.tries == rhs.tries {
        return true
    }
    else {
        return false
    }
}



