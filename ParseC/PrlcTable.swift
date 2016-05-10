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
        guard ref != nil else { return nil } // ref != NULL
        return ref
    }
    
    func indexOf(treeNode : PrlcTreeNodeRef) -> size_t? {
        guard treeNode != nil else { return nil }
        guard let base = self[0] else { return nil }
        let distance = base.distanceTo(treeNode)
        
        assert(distance < treeStoreSize)
        
        return distance
    }
    
    func indexOf(symbol : PrlcStringRef) -> size_t? {
        guard symbol != nil else { return nil }
        
        let base = prlcFirstSymbol(store)
        guard base != nil else { return nil }
        let distance = base.distanceTo(symbol)
        
        assert (distance < symbolStoreSize)
        
        return distance
    }
}

extension PrlcTable {

    private func descendant (ancestor:PrlcTreeNodeRef?, advance:(PrlcTreeNodeRef)->PrlcTreeNodeRef) -> PrlcTreeNodeRef? {
        
        guard let ancestor = ancestor else { return nil }
        
        assert(indexOf(ancestor) < self.treeStoreSize)
        
        let result = advance(ancestor)
        guard result != nil else { return nil }
        
        assert(indexOf(result) < self.treeStoreSize)
        
        return result
    }
    
    private var sibling : (PrlcTreeNodeRef?) -> PrlcTreeNodeRef? {
        return {
            [unowned self]
            (ancestor:PrlcTreeNodeRef?) -> PrlcTreeNodeRef? in
            self.descendant(ancestor) { $0.memory.sibling }
        }
    }
    
    private var child : (PrlcTreeNodeRef?) -> PrlcTreeNodeRef? {
        return {
            [unowned self]
            (ancestor:PrlcTreeNodeRef?) -> PrlcTreeNodeRef? in
            self.descendant(ancestor) { $0.memory.child }
        }
    }
    
    private var successor : (PrlcTreeNodeRef?) -> PrlcTreeNodeRef? {
        return {
            [unowned self]
            (node:PrlcTreeNodeRef?) -> PrlcTreeNodeRef? in
            
            guard let node = node,
                let index = self.indexOf(node)
                else { return nil }
            
            return self[index+1] // nil if index+1 == treeNodeSize
            
        }
    }
    
    private func children<T>(parent:PrlcTreeNodeRef?, data:PrlcTreeNodeRef->T) -> NySequence<PrlcTreeNodeRef,T>{
        
        return NySequence(first: self.child(parent), step:sibling, data:data)
    
    }
}

extension PrlcTable {
    
    

    func tptpSequence<T>(data:(PrlcTreeNodeRef)->T) -> NySequence<PrlcTreeNodeRef,T> {
        return children(self[0]) { data($0) }
    }
    
    var tptpSequence : NySequence<PrlcTreeNodeRef,prlc_tree_node>{
        return tptpSequence { $0.memory }
    }
    
    func nodes<T>(data:(PrlcTreeNodeRef) -> T) -> NySequence<PrlcTreeNodeRef,T> {
        return NySequence(first:self[0], step:successor, data:data)
    }
    
    var nodes: NySequence<PrlcTreeNodeRef,prlc_tree_node> {
        return nodes { $0.memory }
    }
}


