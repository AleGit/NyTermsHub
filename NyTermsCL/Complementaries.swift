//
//  File.swift
//  NyTerms
//
//  Created by Alexander Maringele on 16.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

let tptpFiles = [
    "puz001" : "PUZ001-1".p,
    "hwv066" : "HWV066-1".p, //   15233,  35166
    "hwv074" : "HWV074-1".p, //    2581,   6017
    "hwv105" : "HWV105-1".p, //   20900,  52662
    "hwv119" : "HWV119-1".p, //   17783,  53121
    "hwv134" : "HWV134-1".p, // 2332428,6570884
    
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


struct Complementaries {
    
    private static let files = [
        "PUZ001-1", // 0
        "HWV066-1", // 1    15233,   35166
        "HWV074-1", // 2     2581,    6017
        "HWV105-1", // 3    20900,   52662
        "HWV119-1", // 4    17783,   53121
        "HWV134-1", // 5  2332428, 6570884
        
    ]
    
    private static let searches = [classSearch, structSerach, tailSearch, linearSearch]
    
    static let fastest = 0
    static let faster = 1
    static let fast = 2
    static let linear = 3
    
    static func demoFastest() {
        print("\(self.self) \(__FUNCTION__)")
        demo(0..<files.count, fastest...fastest)
    }
    
    static func demo134Fastest() {
        print("\(self.self) \(__FUNCTION__)")
        demo(5...5, fastest...fastest)
    }
    
    static func demo105Linear() {
        print("\(self.self) \(__FUNCTION__)")
        demo(3...3,linear..<searches.count)
        
    }
    
    private static var classSearch = {
        (literals :[TptpNode]) -> (Int,String) in
        return trieSearch(TrieClass<SymHop,Int>(), literals:literals)
    }
    
    private static var structSerach = {
        (literals :[TptpNode]) -> (Int,String) in
        return trieSearch(TrieStruct<SymHop,Int>(), literals:literals)
    }
    
    private static var tailSearch = {
        (literals :[TptpNode]) -> (Int,String) in
        return trieSearch(TailTrie<SymHop,Int>(), literals:literals)
    }
    
    private static func process<N:Node>(literals:[N], search: (literals:[N]) -> (Int,String)) {
        print("\tProcessing \(literals.count) literals ...:")
        let (count,info) = search(literals:literals)
        print(count,info)
        
    }

    private static func demo(franges:Range<Int>, _ sranges:Range<Int>) {
        print("\(self.self) \(__FUNCTION__) \(franges) \(sranges)\n")
        
        for file in files[franges] {
            guard let problem = file.p else {
                let d = errorNumberAndDescription()
                let message = "file \(file) was not accessible. \(d)"
                print(message)
                continue
            }
            
            print(file,problem)
            var start = CFAbsoluteTimeGetCurrent()
            let formulae = parseFile(problem)
            print("\(formulae.count) formulae parsed in \((CFAbsoluteTimeGetCurrent() - start).timeIntervalDescriptionMarkedWithUnits)")
            start = CFAbsoluteTimeGetCurrent()
            let nodes = literals(formulae)
            print("\(nodes.count) literals) extracted in \((CFAbsoluteTimeGetCurrent() - start).timeIntervalDescriptionMarkedWithUnits)")
            
            for search in searches[sranges] {
                print("")
                var runtime : CFAbsoluteTime = 0
                
                (_, runtime) = measure { process(nodes, search:search) }
                
                
                print ("runtime:",runtime.timeIntervalDescriptionMarkedWithUnits)
                
            }
            
            print("\n")
        }
        
    }
}
