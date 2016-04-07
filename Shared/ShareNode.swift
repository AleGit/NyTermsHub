import Foundation

// MARK: mandatory

protocol SharingNode : Node {
    static func singular(node:Self) -> Self
}

extension SharingNode where Symbol == String {
    
    init<N:Node>(_ s:N) {
        if let nodes = s.nodes {
            self = Self(symbol: s.symbolString(), nodes: nodes.map { Self($0) })
        }
        else {
            self = Self(variable: s.symbolString())
        }
        
        self = Self.singular(self)
    }
}

//final class ShareNode : SharingNode {
//    static var repository = Set<ShareNode>(minimumCapacity:32000)
//    
//    var symbol: String
//    var nodes : [ShareNode]?
//    
//    init(symbol:String, nodes:[ShareNode]?) {
//        self.symbol = symbol
//        self.nodes = nodes
//    }
//    
//    static func singular(node:ShareNode) -> ShareNode {
//        guard let index = repository.indexOf(node) else {
//            return node
//        }
//        return repository[index]
//    }
//}
//
//extension ShareNode {
//    convenience init(stringLiteral value: StringLiteralType) {
//        assert(false, "Mandatory \(#function) not implemented yet.")
//        // let term = TptpNode.node(stringLiteral: value)
//        self.init(symbol: "n/a", nodes: nil)
//        
//    }
//}
//
//func ==(lhs:ShareNode, rhs:ShareNode) -> Bool {
//    guard !(lhs === rhs) else { return true }
//    
//    return rhs.isEqual(rhs)
//    
//}




