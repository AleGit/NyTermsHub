import Foundation

/// A trie stores values at paths, i.e. sequences of keys
/// [[wikikpedia]](https://en.wikipedia.org/wiki/TrieStruct)
///
///
struct TrieStruct<K: Hashable, V: Hashable> {
    typealias Key = K
    typealias Value = V
    private var trieStore = [Key: TrieStruct<Key, Value>]()
    private var valueStore = Set<Value>()
    
    init() {    }
}

extension TrieStruct : TrieType {
    
    mutating func insert(value: Value) {
        valueStore.insert(value)
    }
    
    mutating func delete(value: Value) -> Value? {
        return valueStore.remove(value)
    }
    
    subscript(key:Key) -> TrieStruct? {
        get { return trieStore[key] }
        set { trieStore[key] = newValue }
    }
    
    var values : [Value]? {
        return Array(valueStore)
    }
}

extension TrieStruct {
    /// get valueStore of `self` and all its successors
    var payload : Set<Value> {
        var collected = valueStore
        for (_,trie) in trieStore {
            collected.unionInPlace(trie.payload)
        }
        return collected
    }
}

extension TrieStruct : Equatable {
    var isEmpty: Bool {
        return trieStore.reduce(valueStore.isEmpty) { $0 && $1.1.isEmpty }
    }
    
}

func ==<K,V>(lhs:TrieStruct<K,V>, rhs:TrieStruct<K,V>) -> Bool {
    if lhs.valueStore == rhs.valueStore && lhs.trieStore == rhs.trieStore {
        return true
    }
    else {
        return false
    }
}

extension TrieStruct {
    var tries : [TrieStruct] {
        let ts = trieStore.values
        return Array(ts)
    }
}

