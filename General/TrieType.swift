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
    /// if path or value do not exist trie stays unchange and nil is returned
    mutating func delete<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C, value:Value) -> Value?
    
//    func retrieve<C:CollectionType,S:SequenceType where
//        C.Generator.Element == Key, C.SubSequence.Generator.Element == Key,
//        S.Generator.Element == Value
//        >(path:C) -> S?
    
    func retrieve<C:CollectionType where C.Generator.Element == Key,
        C.SubSequence.Generator.Element == Key>(path:C) -> [Value]?
    
    var isEmpty : Bool { get }
}

extension TrieType where Value==Int {
    typealias KeyPath = [Key]
    
    mutating func fill<S:SequenceType where S.Generator.Element == KeyPath>(nodes:[TptpNode], f:(TptpNode) -> S ) {
        for (index,node) in nodes.enumerate() {
            for path in f(node) {
                self.insert(path, value:index)
            }
        }
    }
    
    mutating func fill(nodes:[TptpNode], f:(TptpNode) -> KeyPath ) {
        for (index,node) in nodes.enumerate() {
            self.insert(f(node), value:index)
        }
    }
}



