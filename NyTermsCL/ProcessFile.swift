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








func process(file:String, search: (literals:[TptpNode]) -> (Int,String)) {
    print("\tprocess file \(file)")
    
    var start = CFAbsoluteTimeGetCurrent()
    let formulae = parseFile(file)
    
    print("\t\(formulae.count) formulae parsed in \(desc(CFAbsoluteTimeGetCurrent() - start, 1))")
    start = CFAbsoluteTimeGetCurrent()
    
        
        let nodes = literals(formulae)
    print("\t\(nodes.count) literals extracted in \(desc(CFAbsoluteTimeGetCurrent() - start, 1))")
    start = CFAbsoluteTimeGetCurrent()
    let (count,info) = search(literals:nodes)
    print("\t\(count) complementary literals found (\(info)) in \(desc(CFAbsoluteTimeGetCurrent() - start,1))")
}
