//
//  MereParser.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

func mereParse(path:TptpPath) -> Int32 {
    let file = fopen(path,"r")  // open file to read
    
    guard file != nil else { return -1 }
    guard let size = path.fileSize where size > 0 else {
        return -1
    }
    
    defer {
        fclose(file)
    }
    
    parsingTable = calmMakeParsingTable(size)
    defer {
        print("calmDeleteParsingTable")
        calmDeleteParsingTable(&parsingTable)
    }
    
    mere_in = file
    mere_restart(file)
    mere_lineno = 1
    
    let code = mere_parse()
    
    
    
    let value = calmGetTreeNodeSize(parsingTable);
    
    
    print(lastInput, value)
    
    for i in 0..<value {
        print(i, String.fromCString(calmGetTreeNodeSymbol(parsingTable,i))!)
    }
    
    #if DEBUG
    
    var sid = calmNextSymbol(parsingTable, 0);
    while sid != 0 && sid < 300 {
        if sid > 160 {
            let string = String.fromCString( calmGetSymbol(parsingTable, sid) )
            print(sid,string)
        }
        
        sid = calmNextSymbol(parsingTable, sid);
    }
    #endif
    
    return code
}
