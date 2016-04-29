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
    
    symbolTable = calmMakeParsingTable(size)
    defer {
        print("calmDeleteParsingTable")
        calmDeleteParsingTable(&symbolTable)
    }
    
    mere_in = file
    mere_restart(file)
    mere_lineno = 1
    
    let code = mere_parse()
    
//    var sid = calmNextSymbol(symbolTable, 0);
//    while sid != 0 {
//        let string = String.fromCString( calmGetSymbol(symbolTable, sid) )
//        print(sid,string)
//        
//        sid = calmNextSymbol(symbolTable, sid);
//    }
    
    return code
}
