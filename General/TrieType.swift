import Foundation

protocol TrieType {
    typealias Key
    typealias Value
    
    /// inserts value at key path
    mutating func insert<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value)
    
    /// deletes value at key path, empty tries should be removed,
    /// if value exists at tree path, value should be returned.
    mutating func delete<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value) -> Value?
}



