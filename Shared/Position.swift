//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// **Definition 2.1.14.** A position is a finite sequence of positive integers.
/// The *root* position is the empty sequence and denoted by `ε`
/// and `p+q` denotes the concatenation of positions `p` and `q`.
/// We define binary relations <= , <, and || on positions as follows.
/// We say that position `p` is above position `q 
/// if there exists a (necessarily unique) position `r` such that `p+r = q`.
/// In that case wedefine `q\p` as the position r.
/// If `p` is above q we also say that `q` is below p or p is a *prefix* of `q`, and we write `p` <= `q`.
/// We write `p < q` if `p <= q` and `p != q`. If `p < q` we say that `p` is a proper prefix of `q`.
/// Positions `p`, q are parallel, denoted by `p || q`, if neither `p <= q` nor `q <= p`.
public typealias Position = [Int]

public func -<T:Equatable>(lhs:[T], rhs:[T]) -> [T]? {
    guard rhs <= lhs else { return nil }
    
    return Array(lhs.suffixFrom(rhs.count))
}

public func <= <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    // lhs must not be longer then rhs
    guard lhs.count <= rhs.count else { return false }
    
    return lhs[0..<lhs.count] == rhs[0..<lhs.count]
}

public func >= <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    return rhs <= lhs
}

public func < <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    // lhs must be shorter then rhs
    guard lhs.count < rhs.count else { return false }
    
    return lhs[0..<lhs.count] == rhs[0..<lhs.count]
}

public func > <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    return rhs < lhs
}

public func || <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    return !( lhs <= rhs || lhs >= rhs)
}

