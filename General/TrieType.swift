import Foundation

protocol TrieType : Equatable {
    associatedtype Key
    associatedtype Value : Hashable
    
    var payload : Set<Value> { get }
    
    /// creates empty trie type
    init()
    
    /// creates a trie type with one value at key path
    init<C:Collection where C.Iterator.Element == Key,
        C.SubSequence.Iterator.Element == Key>(path:C, value:Value)
    
    /// inserts one value at key path
    mutating func insert<C:Collection where C.Iterator.Element == Key,
        C.SubSequence.Iterator.Element == Key>(_ path:C, value:Value)
    
    /// deletes and returns one value at key path,
    /// if path or value do not exist trie stays unchanged and nil is returned
    mutating func delete<C:Collection where C.Iterator.Element == Key,
        C.SubSequence.Iterator.Element == Key>(_ path:C, value:Value) -> Value?
    
    /// returns all values at path
    func retrieve<C:Collection where C.Iterator.Element == Key,
        C.SubSequence.Iterator.Element == Key>(_ path:C) -> [Value]?
    
    /// checks if trie type has no values
    var isEmpty : Bool { get }
    
    /// stores one value at trie node
    mutating func insert(_ value:Value)
    
    /// deletes and returns one value from trie node
    mutating func delete(_ value:Value) -> Value?
    
    /// get values at trie node
    var values : [Value]? { get }
    
    /// get (or set) subnode with key
    subscript(key:Key) -> Self? { get set }
    
    /// get all immediate subnodes
    var tries : [Self] { get }
    
    
    
}

// MARK: default implementations for init, insert, delete, retrieve

extension TrieType {
    init<C:Collection where C.Iterator.Element == Key,
        C.SubSequence.Iterator.Element == Key>(path:C, value:Value) {
            self.init()
            self.insert(path, value:value)
    }
    
    mutating func insert<S:Collection where S.Iterator.Element == Key,
        S.SubSequence.Iterator.Element == Key>(_ path:S, value:Value) {
            guard let (head,tail) = path.decompose else {
                self.insert(value)
                return
            }
            
            var trie = self[head] ?? Self()
            trie.insert(tail, value: value)
            self[head] = trie
    }
    
    mutating func delete<S:Collection where S.Iterator.Element == Key,
        S.SubSequence.Iterator.Element == Key>(_ path:S, value:Value) -> Value? {
            guard let (head,tail) = path.decompose else {
                return self.delete(value)
            }
            
            guard var trie = self[head] else { return nil }
            let v = trie.delete(tail, value:value)
            self[head] = trie.isEmpty ? nil : trie
            return v
    }
    
    func retrieve<C:Collection where
        C.Iterator.Element == Key, C.SubSequence.Iterator.Element == Key>(_ path:C) -> [Value]? {
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
    
    mutating func fill<N:Node, R:Sequence, S:Sequence where
        R.Iterator.Element == N,
        S.Iterator.Element == KeyPath>(_ nodes:R, paths:(N) -> S ) {
            for (index,node) in nodes.enumerated() {
                for path in paths(node) {
                    self.insert(path, value:index)
                }
            }
    }
    
    mutating func fill<N:Node, R:Sequence where
        R.Iterator.Element == N>(_ nodes:R, path:(N) -> KeyPath) {
            for (index,node) in nodes.enumerated() {
                self.insert(path(node), value:index)
            }
    }
}

extension TrieType where Value:Hashable {
    var payload : Set<Value> {
        guard let vals = values else { return Set<Value>() }
        return Set(vals)
    }
    
}

func extractUnifiables<T:TrieType where T.Key==SymHop<String>, T.Value:Hashable>(_ trie:T, path:[T.Key]) -> Set<T.Value>? {
    guard let (head,tail) = path.decompose else {
        return trie.payload
    }
    
    switch head {
    case .hop(_):
        guard let subtrie = trie[head] else { return nil }
        return extractUnifiables(subtrie, path:tail)
    case .symbol("*"):
        // collect everything
        return Set(trie.tries.flatMap { $0.payload })
        
    default:
        // collect variable and exeact match
        
        let variables = trie[.symbol("*")]?.payload
        
        guard let exactly = trie[head] else {
            return variables
        }
        
        guard var payload = extractUnifiables(exactly, path:tail) else {
            return variables
        }
        
        
        if variables != nil {
            payload.formUnion(variables!)
        }
        return payload
        
    }
}


/// extract exact path matches
func extractVariants<T:TrieType where T.Key==SymHop<String>, T.Value:Hashable>(_ trie:T, path:[T.Key]) -> Set<T.Value>? {
    guard let (head,tail) = path.decompose else {
        return trie.payload
    }
    
    guard let subtrie = trie[head] else { return nil }
    
    return extractVariants(subtrie, path:tail)
}

private func candidates<T:TrieType, N:Node where T.Key==SymHop<String>, T.Value:Hashable, N.Symbol==String>(
    _ indexed:T,
    queryTerm:N,
    extract:(T, path:[T.Key]) -> Set<T.Value>?
    
    ) -> Set<T.Value>? {
    
    guard let (first,tail) = queryTerm.paths.decompose else { return nil }
    
    guard var result = extract(indexed, path: first) else { return nil }
    
    for path in tail {
        guard let next = extract(indexed, path:path) else { return nil }
        result.formIntersection(next)
    }
    return result
}

func candidateComplementaries<T:TrieType, N:Node where T.Key==SymHop<N.Symbol>, T.Value:Hashable, N.Symbol==String>(_ indexed:T, term:N) -> Set<T.Value>? {
    var queryTerm: N
    switch term.symbol {
    case "~":
        queryTerm = term.nodes!.first!
    case "!=":
        queryTerm = N(symbol: "=", nodes: term.nodes)
    case "=":
        queryTerm = N(symbol:"!=", nodes: term.nodes)
    default:
        queryTerm = N(symbol:"~", nodes: [term])
    }
    return candidates(indexed, queryTerm:queryTerm) { a,b in extractUnifiables(a,path:b) }
}

func candidateVariants<T:TrieType, N:Node where T.Key==SymHop<String>, T.Value:Hashable, N.Symbol==String>(_ indexed:T, term:N) -> Set<T.Value>? {
    return candidates(indexed, queryTerm:term) { a,b in extractVariants(a,path:b) }
}



