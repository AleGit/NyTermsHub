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
        self.size = calmGetTreeNodeStoreSize(tableRef)
    }
    
    func next() -> (id:calm_tid,symbol:String,sibling:calm_tid,last:calm_tid, child:calm_tid,type:UInt32)? {
        guard nextTid < size else {
            return nil
        }
        defer {
            nextTid += 1
        }
        
        let data = calmCopyTreeNodeData(tableRef, nextTid)
        let symbol = String.fromCString(calmGetSymbol(tableRef,data.sid))!
        
        return (id:nextTid , symbol , data.sibling, data.lastSibling, data.child, data.type.rawValue)
    }
}

class ParsingTable {
    let tableRef : CalmParsingTableRef;
    init(size:Int, path:TptpPath) {
        tableRef = calmMakeParsingTable(size)
        calmNodeSetSymbol(tableRef, 0, path)
    }
    
    deinit {
        var copy = tableRef
        print("calmDeleteParsingTable \(calmGetTreeNodeStoreSize(tableRef))")
        calmDeleteParsingTable(&copy)
        assert(copy == nil)
    }
    
    var treeSize : Int {
        return calmGetTreeNodeStoreSize(tableRef)
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
    let theParsing = ParsingTable(size: size, path:path)
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
