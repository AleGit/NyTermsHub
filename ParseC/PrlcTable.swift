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
        let symbol = String(cString: root.pointee.symbol) ?? "(symbol n/a)"
        
        Nylog.info("\(#function) '\(symbol)'")
        Nylog.info("symbols: \(symbolStoreSize) @ \(symbolStoreFillLevel) %")
        Nylog.info("prefixes: \(prefixStoreSize) @ \(prefixStoreFillLevel) %")
        Nylog.info("term nodes: \(treeStoreSize) @ \(treeStoreFillLevel) %")
        
        var copy = store
        prlcDestroyStore(&copy)
        
        assert (copy == nil)
    }
}

extension PrlcTable {
    
    var symbolStoreSize : Int {
        return store.pointee.symbols.size
    }
    
    var prefixStoreSize : Int {
        return store.pointee.p_nodes.size
    }
    
    var treeStoreSize : Int {
        return store.pointee.t_nodes.size
    }
    
    var symbolStoreFillLevel : Int {
        return percent(store.pointee.symbols.size, divisor: store.pointee.symbols.capacity)
    }
    
    var prefixStoreFillLevel : Int {
        return percent(store.pointee.p_nodes.size, divisor: store.pointee.p_nodes.capacity)
    }
    
    var treeStoreFillLevel : Int {
        return percent(store.pointee.t_nodes.size, divisor: store.pointee.t_nodes.capacity)
    }
}

extension PrlcTable {
    private subscript(distance:size_t) -> PrlcTreeNodeRef? {
        let ref = prlcTreeNodeAtIndex(store, distance)
        guard ref != nil else { return nil } // ref != NULL
        return ref
    }
    
    func indexOf(_ treeNode : PrlcTreeNodeRef?) -> size_t? {
        guard treeNode != nil else { return nil }
        guard let base = self[0] else { return nil }
        let distance = base.distance(to: treeNode!)
        
        assert(distance < treeStoreSize)
        
        return distance
    }
    
    func indexOf(symbol : String) -> size_t? {
        
        let base = prlcFirstSymbol(store)
        let symb = prlcGetSymbol(store,symbol)
        
        guard base != nil && symb != nil else { return nil }
        
        let distance = base.distanceTo(symb)
        
        assert (distance < symbolStoreSize)
        
        return distance
    }
}

extension PrlcTable {

    private func descendant (_ ancestor:PrlcTreeNodeRef?, advance:(PrlcTreeNodeRef)->PrlcTreeNodeRef) -> PrlcTreeNodeRef? {
        
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
            self.descendant(ancestor) { $0.pointee.sibling }
        }
    }
    
    private var child : (PrlcTreeNodeRef?) -> PrlcTreeNodeRef? {
        return {
            [unowned self]
            (ancestor:PrlcTreeNodeRef?) -> PrlcTreeNodeRef? in
            self.descendant(ancestor) { $0.pointee.child }
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
    
//    private var nextTptpInclude : (PrlcTreeNodeRef?) -> PrlcTreeNodeRef? {
//        return {
//            // [unowned self]
//            (tptpInput:PrlcTreeNodeRef?) -> PrlcTreeNodeRef? in
//            
//            guard var input = tptpInput else { return nil }
//            
//            
//            
//            assert(input.memory.type == PRLC_FOF
//                || input.memory.type == PRLC_CNF
//                || input.memory.type == PRLC_INCLUDE)
//            
//            while input.memory.sibling != nil {
//                if input.memory.sibling.memory.type == PRLC_INCLUDE {
//                    return input.memory.sibling
//                }
//                
//                input = input.memory.sibling
//                
//            }
//            
//            return nil
//        }
//    }
    
    
    
    private func nextNode(_ node:PrlcTreeNodeRef?, predicate:(PrlcTreeNodeRef)->Bool) -> PrlcTreeNodeRef? {
        guard var input = node where input != nil else { return nil }
        
        while input.pointee.sibling != nil {
            if predicate(input.pointee.sibling) { return input.pointee.sibling }
            
            input = input.pointee.sibling
        }
        return nil
        
    }
    
    private func firstNode(_ predicate:(PrlcTreeNodeRef)->Bool) -> PrlcTreeNodeRef? {
        guard let root = self[0] else { return nil }
        assert(root.pointee.type == PRLC_FILE)
        guard root.pointee.child != nil else { return nil }
        if predicate(root.pointee.child) { return root.pointee.child }
        return nextNode(root.pointee.child, predicate:predicate)
        
        
    }
    
    private func nextTptpInclude (_ tptpInput: PrlcTreeNodeRef?) -> PrlcTreeNodeRef? {
        guard var input = tptpInput else { return nil }
        
        assert(input.pointee.type == PRLC_FOF
            || input.pointee.type == PRLC_CNF
            || input.pointee.type == PRLC_INCLUDE)
        
        while input.pointee.sibling != nil {
            if input.pointee.sibling.pointee.type == PRLC_INCLUDE {
                return input.pointee.sibling
            }
            
            input = input.pointee.sibling
            
        }
        
        return nil
    }
    
    

    private var firstTptpInclude : PrlcTreeNodeRef? {
        guard let root = self[0] else { return nil }
        
        assert(root.pointee.type == PRLC_FILE)
        
        guard root.pointee.child != nil else { return nil }
        
        if root.pointee.child.pointee.type == PRLC_INCLUDE {
            return root.pointee.child
        }
        
        return nextTptpInclude(root.pointee.child)
        
    }
    
    private func children<T>(_ parent:PrlcTreeNodeRef?, data:(PrlcTreeNodeRef)->T) -> NySequence<PrlcTreeNodeRef,T>{
        
        return NySequence(first: self.child(parent), step:sibling, data:data)
    
    }
}

extension PrlcTable {
    
    func cnfs<T>(_ data:(PrlcTreeNodeRef)->T) -> NySequence<PrlcTreeNodeRef,T> {
        let predicate = { (ref:PrlcTreeNodeRef) -> Bool in ref.pointee.type == PRLC_CNF }
        return NySequence(first:firstNode(predicate), step:{
            self.nextNode($0, predicate:predicate)
            }, data:data)
    }
    
    var cnfs : NySequence<PrlcTreeNodeRef,PrlcTreeNodeRef> {
        return cnfs { $0 }
    }
    
    func includes<T>(_ data:(PrlcTreeNodeRef)->T)  -> NySequence<PrlcTreeNodeRef,T> {
        return NySequence(first:firstTptpInclude, step:nextTptpInclude, data:data)
    }
    
    var includes : NySequence<PrlcTreeNodeRef,PrlcTreeNodeRef> {
        return includes { $0 }
    }

    func tptpSequence<T>(_ data:(PrlcTreeNodeRef)->T) -> NySequence<PrlcTreeNodeRef,T> {
        return children(self[0]) { data($0) }
    }
    
    var tptpSequence : NySequence<PrlcTreeNodeRef,PrlcTreeNodeRef>{
        return tptpSequence { $0 }
    }
    
    func nodes<T>(_ data:(PrlcTreeNodeRef) -> T) -> NySequence<PrlcTreeNodeRef,T> {
        return NySequence(first:self[0], step:successor, data:data)
    }
    
    var nodes: NySequence<PrlcTreeNodeRef,PrlcTreeNodeRef> {
        return nodes { $0 }
    }
}


