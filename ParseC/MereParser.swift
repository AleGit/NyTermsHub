//
//  MereParser.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

class ParsingTable {
    let table : CalmParsingTableRef;
    init(size:Int) {
        table = calmMakeParsingTable(size)
    }
    
    deinit {
        var copy = table
        calmDeleteParsingTable(&copy)
        assert(copy == nil)
    }
}

func mereParse(path:TptpPath) -> (Int32, ParsingTable?) {
    let file = fopen(path,"r")  // open file to read
    
    guard file != nil else {
        print("File \(path) could not be opened.")
        return (-1,nil)
    }
    // file was opened so it must be closed eventually.
    defer {
        fclose(file)
    }
    
    guard let size = path.fileSize where size > 0 else {
        print("File \(path) is empty.")
        return (-1,nil)
    }
    
    // allocate memory depending on the size of the file
    let theParsing = ParsingTable(size: size)
    parsingTable = theParsing.table
    
    mere_in = file
    mere_restart(file)
    mere_lineno = 1
    
    let code = mere_parse()
    
    if code != 0 {
        print("Parsing of \(path) failed with \(code).")
        return (code,nil)
    }
    
    
    return (code,theParsing)
}
