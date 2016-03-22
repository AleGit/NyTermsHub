import Foundation

// MARK: mandatory

final class ShareNode : Node {
    var symbol: String
    var nodes : [ShareNode]?
    
    init(symbol:String, nodes:[ShareNode]?) {
        self.symbol = symbol
        self.nodes = nodes
    }
}

extension ShareNode {
    convenience init(stringLiteral value: StringLiteralType) {
        assert(false, "Mandatory \(__FUNCTION__) not implemented yet.")
        // let term = TptpNode.node(stringLiteral: value)
        self.init(symbol: "n/a", nodes: nil)
        
    }
}

func ==(lhs:ShareNode, rhs:ShareNode) -> Bool {
    guard !(lhs === rhs) else { return true }
    
    return rhs.isEqual(rhs)
    
}




