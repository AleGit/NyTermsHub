//
//  PrlcTable.swift
//  NyTerms
//
//  Created by Alexander Maringele on 09.05.16.
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
        print("symbols:    \(symbolStoreSize) @ \(symbolStoreFillLevel) %")
        print("prefixes:   \(prefixStoreSize) @ \(prefixStoreFillLevel) %")
        print("term nodes: \(treeStoreSize) @ \(treeStoreFillLevel) %")
        
        var copy = store
        prlcDestroyStore(&copy)
        
        assert (copy == nil)
    }
}

extension PrlcTable {
    
    var symbolStoreSize : Int {
        return store.memory.symbols.size
    }
    
    var prefixStoreSize : Int {
        return store.memory.p_nodes.size
    }
    
    var treeStoreSize : Int {
        return store.memory.t_nodes.size
    }
    
    var symbolStoreFillLevel : Int {
        return percent(store.memory.symbols.size, divisor: store.memory.symbols.capacity)
    }
    
    var prefixStoreFillLevel : Int {
        return percent(store.memory.p_nodes.size, divisor: store.memory.p_nodes.capacity)
    }
    
    var treeStoreFillLevel : Int {
        return percent(store.memory.t_nodes.size, divisor: store.memory.t_nodes.capacity)
    }
}
