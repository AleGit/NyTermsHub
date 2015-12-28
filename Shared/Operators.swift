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

/// `s ** t` substitutes all variables in `s` with term `t`.
infix operator ** {
associativity left
}

/// `t**` substitutes all veriables in `t` with constant `⊥`.
postfix operator ** { }
