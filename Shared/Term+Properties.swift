//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

public extension Term {

    /// Simple check if `self` represents a variable, 
    /// i.e. a leaf node without a list of subnodes.
    public var isVariable : Bool {
        return self.terms == nil
    }
    
    /// Simple check if `self` represents a constant (function),
    /// i.e. a node with an empty list of subnodes.
    public var isConstant : Bool {
        guard let terms = self.terms else { return false }
        return terms.count == 0
    }
    
    /// Check if `self` represents a (non-empty) tuple of variables.
    public var isTupleOfVariables : Bool {
        guard self.symbol.type == SymbolType.Tuple else { return false }
        guard let terms = self.terms else { return false }
        guard terms.count > 0 else { return false } /* a tuple of variables must not be empty */
        return terms.reduce(true) { $0 && $1.isVariable }
    }
    
    /// Costly check if `self` reprsents a valid rewrite rule, i.e.
    /// an equation that satifies the follwong conditions
    /// - the left-hand side is not a variable
    /// - Vars(r) is a subset of Vars(l)
    var isRewriteRule : Bool {
        guard self.isEquation else { return false }
        
        // Since self represents a valid equation we know that
        // self has exactly two subterms and both are valid function terms
        
        let lhs = self.terms!.first!
        let rhs = self.terms!.last!
        
        // We only have to check, that the left-hand side is not a variable
        // and that the right-hand side does not introduce new variables.
        
        guard !lhs.isVariable else { return false }
        guard rhs.allVariables.isSubsetOf(lhs.allVariables) else { return false }
        
        return true
    }
    
    /// Costly check if `self` represents a valid function term
    ///
    /// - a variable `X` is a (function) term
    /// - a constant `c` is a (function) term
    /// - an expression `f(t_1, ..., t_n)` is a (function) term
    /// if `f` is a function symbol and `t_1`,...,`t_n` are (function) terms.
    var isFunction : Bool {
        guard let terms = self.terms else { return true; } // a variable is a term
        guard let category = self.symbol.category else { return terms.reduce(true) { $0 && $1.isFunction } }
        return category == SymbolCategory.Functor && terms.reduce(true) { $0 && $1.isFunction }
    }
    
    /// Costly check if `self` represents the negation of a valid predicate term.
    ///
    /// - an expression `~E` is a negative predicate, if `E` is a predicate term.
    private var isNegativePredicate : Bool {
        guard self.symbol.type == SymbolType.Negation else { return false }
        guard let terms = self.terms where terms.count == 1 else { return false }
        
        return terms.first!.isPositivePredicate
    }
    
    /// Costly check if `self` represents a valid predicate term.
    ///
    /// - an expression `p(t_1,...t_n)` is a positive predicate term
    /// if `p` is a predicate symbol and `t_1`,...,`t_n` are (function) terms.
    private var isPositivePredicate : Bool {
        guard let type = self.symbol.type where type == SymbolType.Predicate else { return false }
        guard let terms = self.terms else { return false }
        
        return terms.reduce(true) { $0 && $1.isFunction }
    }
    
    /// Costly check if `self` represents a valid inequation or the negation of a valid equation.
    ///
    /// - an expression `s ≠ t` is an inequation if `s` and `t` are functions.
    /// - an expression `~E` is the negation of an equation, if `E` is an equation.
    private var isInequation : Bool {
        guard let type = self.symbol.type else { return false }
        guard let terms = self.terms else { return false }
        
        switch (type, terms.count) {
        case (.Negation, 1):
            return terms.first!.isEquation
            
        case (.Inequation, 2):
            return terms.first!.isFunction && terms.last!.isFunction
        default:
            return false
        }
    }
    
    /// Costly check if `self` represents an equation.
    ///
    /// - an expression `s = t` is an inequation if `s` and `t` are functions.
    public var isEquation : Bool {
        guard let type = self.symbol.type where type == SymbolType.Equation else { return false }
        guard let terms = self.terms where terms.count == 2 else { return false }
        return terms.first!.isFunction && terms.last!.isFunction
    }
    
    /// Costly check if `self` represents the negation of an valid atomic formula.
    private var isNegativeLiteral : Bool {
        return self.isInequation || self.isNegativePredicate
    }
    
    /// Costly check if `self` represents an atomic formula.
    private var isPositiveLiteral : Bool {
        return self.isEquation || self.isPositivePredicate
    }
    
    /// Costly check if `self` represents a literal.
    public var isLiteral : Bool {
        return self.isPositiveLiteral || self.isNegativeLiteral
    }
    
    /// Costly check if `self` is a first order logic formula.
    ///
    /// - a formula is either a literal or a connection of literals
    private var isFormula : Bool {
        guard !self.isLiteral else { return true }
        
        guard let quadruple = self.symbol.quadruple
            where quadruple.category == SymbolCategory.Connective
            else {
                // undefined or non-connective symbol
                return false
        }
        guard let terms = self.terms
            where quadruple.arity.contains(terms.count)
            else {
                // self has wrong number of subterms
                return false
        }
        
        return terms.reduce(true) { $0 && $1.isFormula }
    }
    
    /// Costly check if `self` represents a disjunction of literals.
    public var isDisjunctionOfLiterals : Bool {
        guard !self.isLiteral else { return true }
        
        guard self.symbol.type == SymbolType.Disjunction else { return false }
        
        guard let terms = self.terms else { return false }
        
        return terms.reduce(true) { $0 && $1.isDisjunctionOfLiterals }
    }
    
    public var isClause : Bool {
        return self.isDisjunctionOfLiterals
    }
    
}
