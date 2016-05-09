//
//  MereParser.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

func prlcParse(path:TptpPath) -> (Int32, PrlcTable?) {
    let file = fopen(path,"r")  // open file to read
    
    let text = "\(#function)('\(path)')"
    
    guard file != nil else {
        print("<<< !!! >>> \(text) file could not be opened. <<< !!! >>>")
        return (-1,nil)
    }
    // file was opened so it must be closed eventually.
    defer {
        fclose(file)
        print(text,"\(#function) file closed.")
    }
    
    guard let size = path.fileSize where size > 0 else {
        print("<<< !!! >>> \(text) file is empty. <<< !!!! >>>")
        return (-1,nil)
    }
    
    // allocate memory depending on the size of the file
    
    let table = PrlcTable(size: size,path: path)
    
    prlcParsingStore = table.store
    prlcParsingRoot = table.root
    defer {
        prlcParsingStore = nil
        prlcParsingRoot = nil
        print(text,"\(#function) store=nil.")
    }
    
    prlc_in = file
    prlc_restart(file)
    prlc_lineno = 1
    
    let code = prlc_parse()
    
    if code != 0 {
        print("<<< !!! >>> \(text) parsing failed (\(code)). <<< !!!! >>>")
        return (code,table)
    }
    
    
    return (code, table)
}
