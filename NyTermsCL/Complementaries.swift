//
//  File.swift
//  NyTerms
//
//  Created by Alexander Maringele on 16.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation



private func roots(formulae:[TptpFormula]) -> [TptpNode] {
    return formulae.map { $0.root }
}

private func literals(formulae:[TptpFormula]) -> [TptpNode] {
    return formulae.flatMap {
        $0.root.nodes ?? [TptpNode]()
    }
}


struct Complementaries {
    private static func process<N:Node>(literals:[N], search: (literals:[N]) -> (Int,String)) -> Int {
        print("\tProcessing \(literals.count) literals ...:")
        let (count,info) = search(literals:literals)
        print(count,info)
        return count
    }
    
    static func demo<F:SequenceType, S:SequenceType where
        F.Generator.Element == String, S.Generator.Element == ([TptpNode])->(Int,String)>
        (files:F, searches:S) {
            print("\(self.self) \(__FUNCTION__).\n")
            defer {
                print("\n")
            }
            
            for file in files {
                guard let path = file.p else {
                    let d = errorNumberAndDescription()
                    let message = "file \(file) was not accessible. \(d)"
                    print(message)
                    continue
                }
                
                print(file,path)
                var start = CFAbsoluteTimeGetCurrent()
                let (_,formulae,_) = parse(path:path)
                print("\(formulae.count) formulae parsed in \((CFAbsoluteTimeGetCurrent() - start).timeIntervalDescriptionMarkedWithUnits)")
                start = CFAbsoluteTimeGetCurrent()
                let nodes = literals(formulae)
                
                print("\(nodes.count) literals) extracted in \((CFAbsoluteTimeGetCurrent() - start).timeIntervalDescriptionMarkedWithUnits)")
                
                for search in searches {
                    print("")
                    var runtime : CFAbsoluteTime = 0
                    
                    (_, runtime) = measure { process(nodes, search:search) }
                    
                    
                    print ("runtime:",runtime.timeIntervalDescriptionMarkedWithUnits)
                    
                }
                
                guard let info = Infos.files[file] else {
                    print("no info found")
                    return
                }
                
                assert(info.0 == formulae.count)
                assert(info.1 == nodes.count)
            }
            
    }
}
