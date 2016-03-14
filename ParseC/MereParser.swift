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
    
    defer {
        fclose(file)
    }
    
    mere_in = file
    mere_restart(file)
    mere_lineno = 1
    
    let code = mere_parse()
    return code
}
