import Foundation

/// A trie stores values at paths, i.e. sequences of keys
/// [[wikikpedia]](https://en.wikipedia.org/wiki/Trie)
///
///
struct Trie<K: Hashable, V: Hashable> {
    typealias Key = K
    typealias Value = V
    private var tries = [Key: Trie<Key, Value>]()
    private (set) var values = Set<Value>()
    
    init() {    }
}

extension Trie : TrieType {
    
    mutating func insert<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) {
            guard let (head,tail) = path.decompose else {
                values.insert(value)
                return
            }
            
            var trie = tries[head] ?? Trie()
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
}

extension Trie {
    mutating func insert(path: [Key], value:Value) {
        guard let (head,tail) = path.decompose else {
            values.insert(value)
            return
        }
        
        var trie = tries[head] ?? Trie()
        trie.insert(tail, value: value)
        tries[head] = trie
    }
    
    mutating func delete(path:[Key], value:Value) -> Value? {
        guard let (head,tail) = path.decompose else {
            return values.remove(value)
        }
        
        guard var trie = tries[head] else { return nil }
        let v = trie.delete(tail, value:value)
        tries[head] = trie.isEmpty ? nil : trie
        return v
    }
}

extension Trie {
    
    
    func generate() -> DictionaryGenerator<Key, Trie<Key, Value>> {
        let generator = tries.generate()
        return generator
    }
    
    var subtries : [Key: Trie<Key, Value>] {
        return tries
    }
    
    var isEmpty: Bool {
        return tries.reduce(values.isEmpty) { $0 && $1.1.isEmpty }
    }
    
    /// retrieves subtrie at key path.
    /// if key path does not exist nil will be returned
    subscript(path:[Key]) -> Trie? {
        guard let (head,tail) = path.decompose else { return self }
        
        guard let trie = tries[head] else { return nil }
        
        return trie[tail]
    }
    
    subscript(key:Key) -> Trie? {
        return tries[key]
    }
    

}

extension Trie {
    /// get values of `self` and all its successors
    var payload : Set<Value> {
        var collected = values
        for (_,trie) in tries {
            collected.unionInPlace(trie.payload)
        }
        return collected
    }
}



