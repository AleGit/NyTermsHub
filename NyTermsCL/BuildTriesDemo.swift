//
//  BuildTriesDemo.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

func buildTriesDemo() {
    
    for name in [ "LCL129-1", "SYN000-2", "PUZ051-1", "HWV074-1", "HWV105-1" ] {
        let literals = TptpNode.literals(name.p)
        var trie = Trie<SymHop,Int>()
        let start = CFAbsoluteTimeGetCurrent()
        trie.fill(literals)
        let duration = CFAbsoluteTimeGetCurrent() - start
        print(name,literals.count,duration, duration/Double(literals.count))
    }
    
    
    
}
