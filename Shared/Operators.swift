//  Copyright © 2015 Alexander Maringele. All rights reserved.

/// Is left-hand side a variant of righ-hand side? (unused)
infix operator ~~ {
associativity none
precedence 130
}

/// Construct unifier of left-hand side and right-hand side.
infix operator =?= {
associativity none
}

/// Construct unifier for clashing literals
infix operator ~?= {
associativity none
}

/// - `t:term ** u:term` substitutes all variables in `t` with term `u`.
/// - `t:term ** i:int` appends "@i" to any variable name.
/// - `t:term ** s:string` replaces every variable name with string `s`.
infix operator ** {
associativity left
}

/// `t⊥` substitutes all veriables in `t` with constant `⊥`.
postfix operator ⊥ { }
