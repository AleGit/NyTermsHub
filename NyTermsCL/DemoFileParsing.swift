//  Created by alm on 30/08/15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

struct DemoFileParsing {
    
    static func demoPrlcParseHWV134() {
        let path = "HWV134-1".p!
        
        let (result,time) = measure {
            prlcParse(path)
        }
        
        print("\(#function) time:",time.prettyTimeIntervalDescription, result.1?.treeNodeCount)
        assert(time < 40,"\(time)")
        assert(29_953_326 == result.1?.treeNodeCount)
        // 29953326
        
        assert(0 == result.0);
        
        
    }
    
    static func demoMereParseHWV134() {
        let path = "HWV134-1".p!
        
        let (result,time) = measure {
            mereParse(path)
        }
        
        print("\(#function) time:",time.prettyTimeIntervalDescription, result.1?.treeSize)
        assert(29_953_326 == result.1?.treeSize)
        assert(time < 40,"\(time)")
        // 29953326
        
        assert(0 == result.0);
        
        
    }
    
    static func demo() {
        print(self.self,"\(#function)\n")
        
        for name in [ "LCL129-1", "SYN000-2", "PUZ051-1", "HWV074-1", "HWV105-1", "HWV062+1","HWV134+1", "HWV134-1" ] {
            let path = name.p!  // file must be accessible
            
            let (formulae, duration) = measure {
                TptpNode.roots(path)
            }
            
            print(name,
                formulae.count,
                "formulae read in",
                duration.prettyTimeIntervalDescription,
                "from",
                path)
        }
    }
    
    static func dimensionsDemo() {
        print(self.self,"\(#function)\n")
        
        for name in [ "LCL129-1", "SYN000-2", "PUZ051-1", "HWV074-1", "HWV105-1", "HWV062+1","HWV134+1",
            // "HWV134-1"
            ] {
                
                guard let path = name.p else {
                    print("\(name) is not accessible in \(TptpPath.tptpRootPath).")
                    continue
                }
                
                print(path)
                
                let (parseResult, parseTime) = measure {
                    parse(path:path)
                }
                
                let (_,tptpFormulae,_) = parseResult
                let count = tptpFormulae.count
                
                print("\(count) formulae parsed in \(parseTime.prettyTimeIntervalDescription)")
                
                let (sizes,countTime) = measure {
                    tptpFormulae.reduce((0,0,0)) {
                        let (x,y,z,_) = $1.root.dimensions()
                        return $0 + (x,y,z)
                    }
                }
                let (h,s,w) = sizes
                print("  total sizes:", sizes)
                print("average sizes:", h/count,s/count,w/count)
                print("   counted in:", countTime.prettyTimeIntervalDescription, "\n")
                
        }
    }
    
    static func parseConvertHWV134() {
        let path = "HWV134-1".p!
        
        let (clauses,parsingTime) = measure {
            return TptpNode.roots(path)
        }
        
        print("parsed :",parsingTime.prettyTimeIntervalDescription, ":",clauses.count, "=", (parsingTime/Double(clauses.count)).prettyTimeIntervalDescription)
        
        
        let (extras, convertingTime) = measure {
            
            return clauses.map { ShareNode.insert($0, belowPredicate: false) }
        }
        
        print("converted", (convertingTime).prettyTimeIntervalDescription, ":", clauses.count, "=", (convertingTime/Double(extras.count)).prettyTimeIntervalDescription)
        
    }
}
