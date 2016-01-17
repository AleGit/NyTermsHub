//
//  File.swift
//  NyTerms
//
//  Created by Alexander Maringele on 16.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

let tptpFiles = [
    "hwv134" : "/Users/Shared/TPTP/Problems/HWV/HWV134-1.p",
    "puz001" : "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p",
    "hwv105" : "/Users/Shared/TPTP/Problems/HWV/HWV105-1.p",
    "hwv074" : "/Users/Shared/TPTP/Problems/HWV/HWV074-1.p",
    
    "hwv119" : "/Users/Shared/TPTP/Problems/HWV/HWV119-1.p"
]

/// Parse HWV134-1.p and construct tree representation.
private func parseFile(path:String) -> [TptpFormula] {
    
    
    let (result,tptpFormulae,tptpIncludes) = parse(path:path)
    
    assert(1 == result.count)
    assert(0 == result.first!)
    assert(2_332_428 == tptpFormulae.count)
    assert(0 == tptpIncludes.count)
    
    return tptpFormulae
}

private func roots(formulae:[TptpFormula]) -> [TptpNode] {
    return formulae.map { $0.root }
}

private func literals(formulae:[TptpFormula]) -> [TptpNode] {
    return formulae.flatMap {
        $0.root.nodes ?? [TptpNode]()
    }
}

let units = ["s", "ms", "ns"]

private func desc(time: CFAbsoluteTime, _ count :Int) -> String {
    
    
    var result = time / Double(count)
    var count = 0
    while result < 1.0 {
        count++
        result *= 1000
    }
    
    return "\(Int(0.5+result))\(units[count])"
    
}

func linearSearch(literals:[TptpNode]) -> (Int,String) {
    let step = 1000
    
    var count = 0
    var stepcount = count
    
    var processed = [TptpNode]()
    
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    
    for newLiteral in literals {
        for oldLiteral in processed {
            if ((newLiteral ~?= oldLiteral) != nil) {
                count++
            }
        }
        processed.append(newLiteral)
        
        if processed.count % step == 0 {
            let now = CFAbsoluteTimeGetCurrent()
            let total = now - start
            let round = now - temp
            
            print("(\(processed.count),\(step)) processed in (\(Int(total))s, \(Int(round))s) (\(desc(total,processed.count)),\(desc(round,step)))",
                "\(count,count-stepcount) complementaries. ")
            temp = now
            stepcount = count
        }
    }
    
    
    return (count, "linear search")
    
}

func extract(trie:Trie<SymHop, TptpNode>, path:TermPath) -> Set<TptpNode>? {
    guard let (head,tail) = path.decompose() else {
        return trie.payload
    }
    
    switch head {
    case .Hop(_):
        guard let subtrie = trie[head] else { return nil }
        return extract(subtrie, path: tail)
    case .Symbol("*"):
        // collect everything
        return Set(trie.subtries.flatMap { $0.1.payload })
        
    default:
        // collect variable and exact match
        
        let variables = trie[.Symbol("*")]?.payload
        
        guard let exactly = trie[head] else {
            return variables
        }
        
        guard var payload = extract(exactly, path:tail) else {
            return variables
        }
        
        
        if variables != nil {
            payload.unionInPlace(variables!)
        }
        return payload
        
        
        
        
    }
    
    
}

func candidates(indexed:Trie<SymHop, TptpNode>, term:TptpNode) -> Set<TptpNode>? {
    var queryTerm : TptpNode
    switch term.symbol {
    case "~":
        queryTerm = term.nodes!.first!
    case "!=":
        queryTerm = TptpNode(symbol: "=", nodes: term.nodes)
    case "=":
        queryTerm = TptpNode(symbol: "!=", nodes: term.nodes)
        
        
    default:
        queryTerm = TptpNode(symbol: "~", nodes: [term])
    }
    
    
    guard let (head,tail) = queryTerm.paths.decompose() else { return nil }
    
    guard var result = extract(indexed, path: head) else { return nil }
    
    for path in tail {
        guard let next = extract(indexed, path:path) else { return nil }
        result.intersectInPlace(next)
    }
    
    
    return result
}

func trieSearch(literals:[TptpNode]) -> (Int,String) {
    let step = 1000
    
    var count = 0
    var stepcount = count
    
    var trie = Trie<SymHop,TptpNode>()
    
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    var processed = 0
    for newLiteral in literals {
        if let candis = candidates(trie, term:newLiteral) {
            for oldLiteral in candis  {
                if ((newLiteral ~?= oldLiteral) != nil) {
                    count++
                }
            }
        }
        
        for path in newLiteral.paths {
            trie.insert(path, value: newLiteral)
            
        }
        processed += 1
        
        if processed % step == 0 {
            let now = CFAbsoluteTimeGetCurrent()
            let total = now - start
            let round = now - temp
            
            print("(\(processed),\(step)) processed in (\(Int(total))s, \(Int(round))s) (\(desc(total,processed)),\(desc(round,step)))",
                "\(count,count-stepcount) complementaries. ")
            temp = now
            stepcount = count
        }
    }
    
    
    return (count,"index search")
}


func process(file:String, search: (literals:[TptpNode]) -> (Int,String)) {
    print("process file \(file)")
    
    var start = CFAbsoluteTimeGetCurrent()
    let formulae = parseFile(file)
    
    print("\(formulae.count) formulae parsed in \(desc(CFAbsoluteTimeGetCurrent() - start, 1))")
    start = CFAbsoluteTimeGetCurrent()
    
        
        let nodes = literals(formulae)
    print("\(nodes.count) literals extracted in \(desc(CFAbsoluteTimeGetCurrent() - start, 1))")
    start = CFAbsoluteTimeGetCurrent()
    let (count,info) = search(literals:nodes)
    print("\(count) complementary literals found (\(info)) in \(desc(CFAbsoluteTimeGetCurrent() - start,1))")
}
