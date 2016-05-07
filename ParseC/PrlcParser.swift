//
//  MereParser.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation


class PrlcTable {
    let root : PrlcTreeNodeRef
    let store : PrlcStoreRef
    
    init(size:Int, path:TptpPath) {
        store = prlcCreateStore(size)
        root = prlcStoreNodeFile(store,path,nil)
    }
    
    deinit {
        let symbol = String.fromCString(root.memory.symbol) ?? "(symbol n/a)"
        
        print("\(#function) '\(symbol)'")
        print("symbols:    \(symbolsStoreSize) @ \(symbolStoreFillDegree) %")
        print("prefixes:   \(prefixStoreSize) @ \(pnodeStoreFillDegree) %")
        print("term nodes: \(treeNodeSize) @ \(tnodeStoreFillDegree) %")
        
        var copy = store
        prlcDestroyStore(&copy)
        
        assert (copy == nil)
    }
}

extension PrlcTable {
    
    var treeNodeSize : Int {
        return store.memory.t_nodes.size
    }
    
    var prefixStoreSize : Int {
        return store.memory.p_nodes.size
    }
    
    var symbolsStoreSize : Int {
        return store.memory.symbols.size
    }
    
    private func fillDegree(size:Int, capacity:Int) -> Int {
        return Int((Double(100*size) / Double(capacity)) + 0.5)
    }
    
    var symbolStoreFillDegree : Int {
        return fillDegree(store.memory.symbols.size, capacity: store.memory.symbols.capacity)
    }
    
    var tnodeStoreFillDegree : Int {
        return fillDegree(store.memory.t_nodes.size, capacity: store.memory.t_nodes.capacity)
    }
    
    var pnodeStoreFillDegree : Int {
        return fillDegree(store.memory.p_nodes.size, capacity: store.memory.p_nodes.capacity)
    }
}

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
