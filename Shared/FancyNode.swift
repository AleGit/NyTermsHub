//
//  FancyNode.swift
//  NyTerms
//
//  Created by Alexander Maringele on 18.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

final class FancyNode : Node {
    var symbol:Int
    var nodes : [FancyNode]?
    
    init(symbol:Int, nodes:[FancyNode]?) {
        self.symbol = symbol
        self.nodes = nodes
    }
}


extension FancyNode {
    static func quintuple(symbol:Int) -> SymbolQuintuple? {
        assert(false, "\(__FUNCTION__) not implemented yet.")
        return nil
    }
    static func symbol(type:SymbolType) -> Int {
        assert(false, "\(__FUNCTION__) not implemented yet.")
        return 0
    }
}

// MARK: Conversion from `Node<Symbol>` to  `FancyNode`.

extension FancyNode {
    convenience init<N:Node where N.Symbol == String>(_ s:N) {
        assert(false, "\(__FUNCTION__) not implemented yet.")
        self.init(symbol:0, nodes:nil)
//        if let nodes = s.nodes {
//            self = Self(symbol: s.symbolString, nodes: nodes.map { Self($0) })
//        }
//        else {
//            self = Self(variable: s.symbolString)
//        }
    }
}

extension FancyNode {
    var description : String {
        return buildDescription {
            "\($0.0)"
        }
    }
}

extension FancyNode {
    convenience init(stringLiteral value: StringLiteralType) {
        assert(false, "\(__FUNCTION__) not implemented yet.")
        // let term = TptpNode.node(stringLiteral: value)
        self.init(symbol: 0, nodes: nil)
    }
}