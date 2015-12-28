import Foundation

public struct Trie<Key: Hashable, Datum: Hashable> {
    var tries = [Key: Trie<Key, Datum>]()
    var data = Set<Datum>()
    
    public init() {    }
}

public extension Trie {
    mutating func insert(path: [Key], datum:Datum) {
        guard let (head,tail) = path.decompose else {
            data.insert(datum)
            return
        }
        
        var trie = tries[head] ?? Trie()
        trie.insert(tail, datum: datum)
        tries[head] = trie
    }
    
    subscript(path:[Key]) -> Trie? {
        guard let (head,tail) = path.decompose else { return self }
        
        guard let trie = tries[head] else { return nil }
        
        return trie[tail]
    }
}

public extension Trie {
    var payload : Set<Datum> {
        var collected = data
        for (_,trie) in tries {
            collected.unionInPlace(trie.payload)
        }
        return collected
    }
}

// MARK: - String Tries 

public func buildStringTrie(words:[String]) -> Trie<Character, String> {
    var trie = Trie<Character,String>()
    
    for word in words {
        let characters = Array(word.characters)
        trie.insert(characters, datum: word)
    }
    
    return trie
}

