import Foundation

protocol TrieType {
    typealias Key
    typealias Value
    
    mutating func insert<S:CollectionType where S.Generator.Element == Key,
        S.SubSequence.Generator.Element == Key>(path:S, value:Value)
    
    //    mutating func delete<S:CollectionType where S.Generator.Element == Key,
    //            S.SubSequence.Generator.Element == Key>(path:S, value:Value)
}



