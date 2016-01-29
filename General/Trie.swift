import Foundation

protocol TrieType {
    typealias Key : Hashable
    typealias Value : Equatable
    
    mutating func insert(path:[Key], value:Value)
    mutating func delete(path:[Key], value:Value)
}

/// [[wikikpedia]](https://en.wikipedia.org/wiki/Trie)
struct Trie<K: Hashable, V: Hashable> : TrieType {
    typealias Key = K
    typealias Value = V
    private var tries = [Key: Trie<Key, Value>]()
    private (set) var values = Set<Value>()
    
    init() {    }
}

extension Trie {
    func generate() -> DictionaryGenerator<Key, Trie<Key, Value>> { 
        let generator = tries.generate()
        return generator
    }
    
    var subtries : [Key: Trie<Key, Value>] {
        return tries
    }
    
    /// follows key path to insert value,
    /// missing key path components will be created.
    mutating func insert(path: [Key], value:Value) {
        guard let (head,tail) = path.decompose() else {
            values.insert(value)
            return
        }
        
        var trie = tries[head] ?? Trie()
        trie.insert(tail, value: value)
        tries[head] = trie
    }
    
    var isEmpty: Bool {
        return tries.reduce(values.isEmpty) { $0 && $1.1.isEmpty }
    }
    
    /// deletes value at key path, empty subtries will be removed.
    /// if key path does not exist nothing happens.
    mutating func delete(path:[Key], value:Value) {
        guard let (head,tail) = path.decompose() else {
            values.remove(value)
            return
        }
        
        guard var trie = tries[head] else { return }
        
        trie.delete(tail, value:value)
        
        tries[head] = trie.isEmpty ? nil : trie
    }
    
    /// retrieves subtrie at key path.
    /// if key path does not exist nil will be returned
    subscript(path:[Key]) -> Trie? {
        guard let (head,tail) = path.decompose() else { return self }
        
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



