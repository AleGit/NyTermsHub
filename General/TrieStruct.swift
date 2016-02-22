import Foundation

/// A trie stores values at paths, i.e. sequences of keys
/// [[wikikpedia]](https://en.wikipedia.org/wiki/TrieStruct)
///
///
struct TrieStruct<K: Hashable, V: Hashable> {
    typealias Key = K
    typealias Value = V
    private (set) var tries = [Key: TrieStruct<Key, Value>]()
    private (set) var valueSet = Set<Value>()
    
    init() {    }
}

extension TrieStruct : TrieType {
    
    mutating func insert(value: Value) {
        valueSet.insert(value)
    }
    
    mutating func delete(value: Value) -> Value? {
        return valueSet.remove(value)
    }
    
    subscript(key:Key) -> TrieStruct? {
        get { return tries[key] }
        set { tries[key] = newValue }
    }
    
    var values : [Value]? {
        return Array(valueSet)
    }
}

extension TrieStruct {
    /// get valueSet of `self` and all its successors
    var payload : Set<Value> {
        var collected = valueSet
        for (_,trie) in tries {
            collected.unionInPlace(trie.payload)
        }
        return collected
    }
}

extension TrieStruct : Equatable {
    var isEmpty: Bool {
        return tries.reduce(valueSet.isEmpty) { $0 && $1.1.isEmpty }
    }
    
}

func ==<K,V>(lhs:TrieStruct<K,V>, rhs:TrieStruct<K,V>) -> Bool {
    if lhs.valueSet == rhs.valueSet && lhs.tries == rhs.tries {
        return true
    }
    else {
        return false
    }
}



