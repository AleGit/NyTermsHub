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

extension PrlcTable {
    private subscript(distance:size_t) -> PrlcTreeNodeRef? {
        let ref = prlcTreeNodeAtIndex(store, distance)
        guard ref != nil else { return nil }
        return ref
    }
    
    private func indexOf(treeNode : PrlcTreeNodeRef) -> size_t {
        guard let base = self[0] else { return 0 }
        return base.distanceTo(treeNode)
    }
    
    private func descendant (ancestor:PrlcTreeNodeRef, f:(PrlcTreeNodeRef)->PrlcTreeNodeRef) -> PrlcTreeNodeRef? {
        
        assert(indexOf(ancestor) < self.treeStoreSize)
        let result = f(ancestor)
        guard result != nil else { return nil }
        assert(indexOf(result) < self.treeStoreSize)
        
        return result
    }
    
    private var sibling : (PrlcTreeNodeRef) -> PrlcTreeNodeRef? {
        return {
            [unowned self]
            (ancestor:PrlcTreeNodeRef) -> PrlcTreeNodeRef? in
            self.descendant(ancestor) { $0.memory.sibling }
        }
    }
    
    private var child : (PrlcTreeNodeRef) -> PrlcTreeNodeRef? {
        return {
            [unowned self]
            (ancestor:PrlcTreeNodeRef) -> PrlcTreeNodeRef? in
            self.descendant(ancestor) { $0.memory.child }
        }
    }
    
    private func children<T>(parent:PrlcTreeNodeRef?, data:PrlcTreeNodeRef->T) -> NySequence<PrlcTreeNodeRef,T>{
        
        let first = parent != nil ? self.child(parent!) : nil
        
        return NySequence(first:first, step:sibling) { data ($0) }
    
    }
    
    var tptpSequence : NySequence<PrlcTreeNodeRef,prlc_tree_node>{
        return children(self[0]) { $0.memory }
    }
}


