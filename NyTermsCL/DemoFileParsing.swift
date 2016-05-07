//  Created by alm on 30/08/15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

protocol PrlcTreeNodeType {
    var symbol : UnsafePointer<Int8> { get }
}

extension prlc_tree_node : PrlcTreeNodeType {
    
}

extension UnsafeMutablePointer where Memory : PrlcTreeNodeType {
    var symbolString : String {
        return String.fromCString(self.memory.symbol) ?? "n/a"
    }
}



private func sibling(base: PrlcTreeNodeRef, node: PrlcTreeNodeRef) -> (Int,String)? {
    let sibling = node.memory.sibling
    guard sibling != nil else { return nil }
    
    return (base.distanceTo(sibling), sibling.symbolString)
    
}

private func child(base: PrlcTreeNodeRef, node: PrlcTreeNodeRef) -> (Int,String)? {
    let child = node.memory.child
    guard child != nil else { return nil }
    
    return (base.distanceTo(child), child.symbolString)
    
}

private func output(node: PrlcTreeNodeRef) {
    guard node != nil else { return }
    
    if node.memory.type.rawValue < 6 { print("") }
    
    print(node.symbolString, terminator:" ")
    output(node.memory.child)
    
    output(node.memory.sibling)
}

struct DemoFileParsing {
    
    
    static func demoPrlcParseHWV134() {
        for name in ["PUZ001-1", "HWV134-1"] {
            guard let path = name.p else { continue }
            
            let (result,time) = measure {
                prlcParse(path)
            }
            
            print("\(#function) time:",time.prettyTimeIntervalDescription, result.1?.treeNodeSize)
            assert(time < 40,"\(time)")
            assert(0 == result.0);
            
            if let table = result.1 {
                let size = table.treeNodeSize
                assert(29_953_326 == size)
                
                
                
                print(table.root.memory)
                print(table.root.symbolString, sibling(table.root, node:table.root), "child:", child(table.root, node: table.root))
                
                var node = table.root
                var count = 0
                while count < min(10,size) {
                    assert(node == table.root.advancedBy(count))
                    // let node = table.root.advanceBy(count)
                    print(count, node.symbolString, "\t\tsibling:",sibling(table.root, node:node), "child:", child(table.root, node: node))
                    count += 1
                    node = node.successor()
                }
                
                // output(table.root)
            }
            else {
                assert(false)
            }
        }
        
        
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
