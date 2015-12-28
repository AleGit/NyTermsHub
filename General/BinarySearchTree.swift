import Foundation

/// binary search tree
indirect enum BinarySearchTree<Element: Comparable> {
    case Leaf
    case Node(BinarySearchTree<Element>, Element, BinarySearchTree<Element>)
}

extension BinarySearchTree {
    init() {
        self = .Leaf
    }
    
    init(_ value: Element) {
        self = .Node(.Leaf, value, .Leaf)
    }
}

extension BinarySearchTree {
    var count: Int {
        switch self {
        case .Leaf:
            return 0
        case let .Node(left, _, right):
            return 1 + left.count + right.count
        }
    }
    var elements: [Element] {
        switch self {
        case .Leaf:
            return []
        case let .Node(left, x, right):
            return left.elements + [x] + right.elements
        }
    }
    
    var isEmpty: Bool {
        if case .Leaf = self {
            return true
        }
        return false
    }
    
    var isBindarySearchTree : Bool {
        switch self {
        case .Leaf:
            return true
        case let .Node(left,x,right):
            return left.elements.all { y in y < x }
                && right.elements.all { y in y > x }
                && left.isBindarySearchTree
                && right.isBindarySearchTree
        }
    }
}

extension BinarySearchTree {
    func contains(x: Element) -> Bool {
        switch self {
        case .Leaf:
            return false
        case let .Node(_, y, _) where x == y:
            return true
        case let .Node(left, y, _) where x < y:
            return left.contains(x)
        case let .Node(_, y, right) where x > y:
            return right.contains(x)
        default:
            fatalError("The impossible occurred")
        }
    }
}

extension BinarySearchTree {
    mutating func insert(x: Element) {
        switch self {
        case .Leaf:
            self = BinarySearchTree(x)
        case .Node(var left, let y, var right):
            if x < y { left.insert(x) }
            if x > y { right.insert(x) }
            self = .Node(left, y, right)
        }
    }
}
