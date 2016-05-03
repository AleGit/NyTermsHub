//
//  MereParser.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

class TreeNodeGenerator<T> : GeneratorType {
    private var tid : calm_tid?
    private var step : (calm_tid) -> calm_tid?
    private var f : (calm_tid) -> T
    
    init(firstTid:calm_tid, step:(calm_tid)->calm_tid?, f: (calm_tid) -> T) {
        self.tid = firstTid
        self.step = step
        self.f = f
    }
    
    func next() -> T? {
        guard let tid = self.tid else { return nil }
    
        defer {
            // will change after return statement
            self.tid = step(tid)
        }
        return f(tid)
    }
}

class TreeNodeSequence<T> : SequenceType {
    private let firstTid : calm_tid
    private let step: (calm_tid) -> calm_tid?
    private var f : (calm_tid) -> T
    
    init(tableRef:CalmParsingTableRef, parentTid:calm_tid, step:(calm_tid) -> calm_tid?, f:(calm_tid)->T) {
        assert(tableRef != nil)
        assert(parentTid < calmGetTreeNodeStoreSize(tableRef))
        
        self.firstTid = calmGetTreeNode(tableRef,parentTid).memory.child
        self.step = step
        self.f = f
    }
    
    init(firstTid:calm_tid, step:(calm_tid) -> calm_tid?, f:(calm_tid)->T) {
        self.firstTid = firstTid
        self.step = step
        self.f = f
    }
    
    func generate() -> TreeNodeGenerator<T> {
        return TreeNodeGenerator(firstTid: firstTid, step:step, f:f)
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
    
    var treeNodes : TreeNodeSequence<(calm_tid,calm_tree_node)> {
        return TreeNodeSequence(firstTid:0, step:self.nextNode) {
            ($0,calmCopyTreeNodeData(self.tableRef,$0))
        }
        
        // return self.siblings(firstTid:0, step:self.nextNode)
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
    
    
    func siblings(firstTid:calm_tid) -> TreeNodeSequence<calm_tid> {
        return TreeNodeSequence(firstTid:firstTid, step:self.nextSibling) {$0}
    }
    
    func children(parentTid:calm_tid) -> TreeNodeSequence<calm_tid> {
        return TreeNodeSequence(tableRef: tableRef, parentTid:parentTid, step:self.nextSibling) {$0}
    }
    
    func siblings<T>(firstTid:calm_tid, g:(CalmParsingTableRef,calm_tid) -> T) -> TreeNodeSequence<T> {
        return TreeNodeSequence(firstTid:firstTid, step:self.nextSibling) {
            g(self.tableRef,$0)
        }
    }
    
    func children<T>(parentTid:calm_tid, g:(CalmParsingTableRef,calm_tid) -> T) -> TreeNodeSequence<T> {
        return TreeNodeSequence(tableRef: tableRef, parentTid:parentTid, step:self.nextSibling) {
            g(self.tableRef,$0)
        }
    }
    
    var tptpSequence : TreeNodeSequence<calm_tid> {
        return TreeNodeSequence(firstTid:self[0]!.child, step:self.nextSibling) { $0 }
    }
    
    subscript(tid:calm_tid) -> calm_tree_node? {
        guard tid < treeSize else { return nil }
        return calmGetTreeNode(tableRef, tid).memory
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
