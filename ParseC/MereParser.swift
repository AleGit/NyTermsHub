//
//  MereParser.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

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
    
    private var nextSibling : (calm_tid) -> calm_tid? {
        return {
            [unowned self]
            (tid:calm_tid) -> calm_tid? in
            assert(tid < calmGetTreeNodeStoreSize(self.tableRef))
            let nextTid = calmGetTreeNode(self.tableRef,tid).memory.sibling
            assert(nextTid < self.treeSize)
            return nextTid > 0 ? nextTid : nil
        }
    }
    private var nextNode : (calm_tid) -> calm_tid? {
        return {
            [unowned self]
            (tid:calm_tid) -> calm_tid? in
            assert(tid < self.treeSize)
            let nextTid = tid + 1
            guard nextTid < self.treeSize else {
                return nil
            }
            return nextTid
        }
    }
    private static func treeNodePair(ref:CalmParsingTableRef,tid:calm_tid)->(calm_tid,calm_tree_node) {
        return (tid, calmGetTreeNode(ref, tid).memory)
    }
    
    func siblings<T>(first:calm_tid?, g:(CalmParsingTableRef,calm_tid) ->T) -> NySequence<calm_tid,T> {
        return NySequence(first:first, step:self.nextSibling){
            g(self.tableRef,$0)
        }
    }
    
    func children<T>(parentTid:calm_tid, g:(CalmParsingTableRef,calm_tid) -> T) -> NySequence<calm_tid,T> {
        let first = calmGetTreeNode(tableRef,parentTid).memory.child
        
        guard first > 0 else { return siblings(nil, g:g) }
        
        return siblings(first, g:g)
    }
    
    func children(parentTid:calm_tid) -> NySequence<calm_tid,(calm_tid,calm_tree_node)> {
        return children(parentTid, g:ParsingTable.treeNodePair)
    }
    
    func siblings(firstTid:calm_tid)  -> NySequence<calm_tid,(calm_tid,calm_tree_node)> {
        return siblings(firstTid, g:ParsingTable.treeNodePair)
    }
    
    var treeNodes : NySequence<calm_tid,(calm_tid,calm_tree_node)> {
        return NySequence(first:0, step:self.nextNode) {
            ParsingTable.treeNodePair(self.tableRef, tid: $0)
        }
    }
    
    var tptpSequence : NySequence<calm_tid,(calm_tid,calm_tree_node)> {
        return self.children(0)
    }
    
        
        

    
    subscript(tid:calm_tid) -> calm_tree_node? {
        guard tid < treeSize else { return nil }
        return calmGetTreeNode(tableRef, tid).memory
    }
    
    var symbols : NySequence<calm_sid,(calm_sid,String)> {
        let step = {
            [unowned self]
            (sid:calm_sid) -> calm_sid? in
            assert(sid < calmGetSymbolStoreSize(self.tableRef))
            let nextSid = calmNextSymbol(self.tableRef, sid)
            guard nextSid > 0 else { return nil }
            return nextSid
        }
        
        let data = {
            [unowned self]
            (sid:calm_sid) -> (calm_sid,String) in
            let cstring = calmGetSymbol(self.tableRef, sid)
            let string = String.fromCString(cstring) ?? "n/a"
            return (sid,string)
        }
        
        return NySequence(first:0,step:step,data:data)
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
