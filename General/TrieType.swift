import Foundation

protocol TrieType : Equatable {
    typealias Key
    typealias Value
    
    init<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C, value:Value)
    
    /// inserts value at key path
    mutating func insert<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C, value:Value)
    /// deletes and returns value at key path,
    /// if path or value do not exist trie stays unchanged and nil is returned
    mutating func delete<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C, value:Value) -> Value?
    /// return the values stored at path
    func retrieve<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C) -> [Value]?
    
    var isEmpty : Bool { get }
    
    init()
    
    mutating func insert(value:Value)
    mutating func delete(value:Value) -> Value?
    subscript(key:Key) -> Self? { get set }
    var values : [Value]? { get }
}

// MARK: default implementations for init, insert, delete, retrieve

extension TrieType {
    init<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C, value:Value) {
            self.init()
            self.insert(path, value:value)
    }
    
    mutating func insert<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) {
            guard let (head,tail) = path.decompose else {
                self.insert(value)
                return
            }
            
            var trie = self[head] ?? Self()
            trie.insert(tail, value: value)
            self[head] = trie
    }
    
    mutating func delete<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) -> Value? {
            guard let (head,tail) = path.decompose else {
                return self.delete(value)
            }
            
            guard var trie = self[head] else { return nil }
            let v = trie.delete(tail, value:value)
            self[head] = trie.isEmpty ? nil : trie
            return v
    }
    
    func retrieve<C:CollectionType where
        C.Generator.Element == Key, C.SubSequence.Generator.Element == Key>(path:C) -> [Value]? {
            guard let (head,tail) = path.decompose else {
                return values
            }
            
            guard let trie = self[head] else { return nil }
            return trie.retrieve(tail)
            
    }
}

extension TrieType {
    subscript(path:[Key]) -> Self? {
        guard let (head,tail) = path.decompose else { return self }
        
        guard let trie = self[head] else { return nil }
        
        return trie[tail]
    }
}

extension TrieType where Value==Int {
    typealias KeyPath = [Key]
    
    mutating func fill<N:Node, R:SequenceType, S:SequenceType where
        R.Generator.Element == N,
        S.Generator.Element == KeyPath>(nodes:R, paths:(N) -> S ) {
            for (index,node) in nodes.enumerate() {
                for path in paths(node) {
                    self.insert(path, value:index)
                }
            }
    }
    
    mutating func fill<N:Node, R:SequenceType where
        R.Generator.Element == N>(nodes:R, path:(N) -> KeyPath) {
            for (index,node) in nodes.enumerate() {
                self.insert(path(node), value:index)
            }
    }
}


