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
}

extension TrieType {
    init<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C, value:Value) {
            self.init()
            self.insert(path, value:value)
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



