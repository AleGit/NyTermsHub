//
//  MereParser.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

class TreeNodeSequence : SequenceType {
    private var tableRef : CalmParsingTableRef
    
    init(tableRef:CalmParsingTableRef) {
        self.tableRef = tableRef
    }
    
    func generate() -> TreeNodeGenerator {
        return TreeNodeGenerator(tableRef: tableRef)
    }
}

class TreeNodeGenerator : GeneratorType {
    private let tableRef : CalmParsingTableRef
    private var nextTid : calm_tid
    private var size : calm_id
    
    init(tableRef:CalmParsingTableRef) {
        self.tableRef = tableRef
        self.nextTid = 0
        self.size = calmGetTreeStoreSize(tableRef)
    }
    
    func next() -> String? {
        guard nextTid < size else {
            return nil
        }
        defer {
            nextTid += 1
        }
        
        let tidRef = calmGetTreeNode(tableRef, nextTid)
        let symbol = String.fromCString(calmGetSymbol(tableRef,tidRef.memory.sid))!
        
        return "\(nextTid) \(symbol) \t sibling:\(tidRef.memory.sibling) child:\(tidRef.memory.child) \t type:\(tidRef.memory.type.rawValue)"
    }
}

class ParsingTable {
    let tableRef : CalmParsingTableRef;
    init(size:Int) {
        tableRef = calmMakeParsingTable(size)
    }
    
    deinit {
        var copy = tableRef
        calmDeleteParsingTable(&copy)
        assert(copy == nil)
    }
    
    var treeSize : Int {
        return calmGetTreeStoreSize(tableRef)
    }
    
    var treeNodes : TreeNodeSequence {
        return TreeNodeSequence(tableRef: tableRef)
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
    mereParsingTable = theParsing.tableRef
    
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
