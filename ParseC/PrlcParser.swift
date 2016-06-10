//
//  MereParser.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

@available(*, deprecated=1.0, message="in construction")
struct PrlcParser {
    
    private static func parseIt(path:TptpPath) -> Int32 {
        let file = fopen(path,"r")  // open file to read
        guard file != nil else {
            assert(false)
            return -1
        }
        defer {
            fclose(file)
        }
        prlc_in = file
        prlc_restart(file)
        prlc_lineno = 1
        
        let code = prlc_parse()
        return code
    }
    
    static func parse(path:TptpPath) -> (table:PrlcTable, files:[(TptpPath,Int32)]) {
        
        // reserve 'enough' memory
        let table = PrlcTable(size:200_000_000, path:path)
        
        prlcParsingStore = table.store
        prlcParsingRoot = table.root
        
        defer {
            prlcParsingStore = nil
            prlcParsingRoot = nil
        }
        
        let code = parseIt(path)
        
        
        var array = [(path,code)]
        
        for inclNode in table.includes {
            guard var name = String.fromCString(inclNode.memory.symbol) else {
                array.append(("",-1))
                continue
            }
            
            if name.hasPrefix("'") {
                assert(name.hasSuffix("'"))
                let start = name.startIndex.advancedBy(1)
                let end = name.endIndex.advancedBy(-1)
                name = name[start..<end]
                
            }
            
            guard let inclPath = path.tptpPathTo(name) else {
                array.append((name,-1))
                continue
            }
            
            Nylog.info("\(name) \(inclPath)")
            
            let code = parseIt(inclPath)
            
            array.append(inclPath, code)
        }
        
        
        
        
        return (table,array)
        
    }
}


func prlcParse(path:TptpPath) -> (Int32, PrlcTable?) {
    let file = fopen(path,"r")  // open file to read
    
    let text = "\(#function)('\(path)')"
    
    guard file != nil else {
        Nylog.error("\(text) file could not be opened. <<< !!! >>>")
        return (-1,nil)
    }
    // file was opened so it must be closed eventually.
    defer {
        fclose(file)
        Nylog.error("text \(#function) file closed.")
    }
    
    guard let size = path.fileSize where size > 0 else {
        Nylog.error("\(text) file is empty. <<< !!!! >>>")
        return (-1,nil)
    }
    
    // allocate memory depending on the size of the file
    
    let table = PrlcTable(size: size,path: path)
    
    prlcParsingStore = table.store
    prlcParsingRoot = table.root
    defer {
        prlcParsingStore = nil
        prlcParsingRoot = nil
        Nylog.error("text \(#function) store=nil.")
    }
    
    prlc_in = file
    prlc_restart(file)
    prlc_lineno = 1
    
    let code = prlc_parse()
    
    if code != 0 {
        Nylog.error("\(text) parsing failed (\(code)). <<< !!!! >>>")
        return (code,table)
    }
    
    
    return (code, table)
}
