//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

struct Pair<L:Hashable,R:Hashable> {
    let left : L
    let right : R
}

// MARK: Equatable
func ==<L,R>(lhs:Pair<L,R>, rhs:Pair<L,R>) -> Bool {
    return lhs.left == rhs.left && lhs.right == rhs.right
}

// MARK: Hashable (requires Equotable)
extension Pair : Hashable {
    var hashValue : Int {
        return left.hashValue &+ right.hashValue
    }
}


