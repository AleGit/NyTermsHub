//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

public extension Term {
    
    /// A variable does not have a list of subterms.
    public var isVariable : Bool {
        return self.terms == nil
    }
    
    public var isTupleOfVariables : Bool {
        guard self.symbol.type == SymbolType.Tuple else { return false }
        guard let terms = self.terms else { return false }
        guard terms.count > 0 else { return false } /* a tuple of variables must not be mepty */
        return terms.reduce(true) { $0 && $1.isVariable }
    }
    
    /// A constant (function) has an empty list of subterms.
    public var isConstant : Bool {
        guard let terms = self.terms else { return false }
        return terms.count == 0
    }
    
    /// Term has on of the symbols in { '=', '⟶' } (preliminary)
    /// and has exactly two subterms.
    public var isEquational : Bool {
        guard self.symbol.category == SymbolCategory.Equational else { return false }
        guard let terms = self.terms else { return false }
        guard terms.count == 2 else { return false }
        return true
    }
    
    /// Costly check if `self` reprsents a valid rewrite rule, i.e.
    /// an equation that satifies the follwong conditions
    /// - the left-hand side is not a variable
    /// - Vars(r) is a subset of Vars(l)
    var isRewriteTree : Bool {
        guard self.isEquationTree else { return false }
        
        // Since self represents a valid equation we know that
        // self has exactly two subterms and both are valid function terms
        
        let lhs = self.terms!.first!
        let rhs = self.terms!.last!
        
        // We only have to check, that the left-hand side is not a variable
        // and that the right-hand does not introduce new variables.
        
        guard lhs.terms != nil else { return false }   // the left hand side must not be a variable
        guard rhs.allVariables.isSubsetOf(lhs.allVariables) else { return false }
        
        return true
    }
    
    /// To be used in assertions.
    
    
    
    
    
    
    /// Costly check if `self` represents a (function) term
    ///
    /// - a variable `X` is a (function) term
    /// - a constant `c` is a (function) term
    /// - an expression `f(t_1, ..., t_n)` is a (function) term
    /// if `f` is a function symbol and `t_1`,...,`t_n` are (function) terms.
    var isFunctionTree : Bool {
        guard let terms = self.terms else { return true; } // a variable is a term
        guard let category = self.symbol.category else { return terms.reduce(true) { $0 && $1.isFunctionTree } }
        return category == SymbolCategory.Functor && terms.reduce(true) { $0 && $1.isFunctionTree }
    }
    
    /// Costyl check if `self` represents the negation of a predicate term.
    ///
    /// - an expression `~E` is a negative predicate, if `E` is a predicate term.
    private var isNegativePredicateTree : Bool {
        guard self.symbol.type == SymbolType.Negation else { return false }
        guard let terms = self.terms where terms.count == 1 else { return false }
        
        return terms.first!.isPositivePredicateTree
    }
    
    /// Costly check if `self` represents a predicate term.
    ///
    /// - an expression `p(t_1,...t_n)` is a positive predicate term
    /// if `p` is a predicate symbol and `t_1`,...,`t_n` are (function) terms.
    private var isPositivePredicateTree : Bool {
        guard let type = self.symbol.type where type == SymbolType.Predicate else { return false }
        guard let terms = self.terms else { return false }
        
        return terms.reduce(true) { $0 && $1.isFunctionTree }
    }
    
    /// Costly check if `self` represents the negation of an equation.
    ///
    /// - an expression `s ≠ t` is an inequation if `s` and `t` are function terms.
    /// - an expression `~E` is the negation of an equation, if `E` is an equation.
    private var isInequationTree : Bool {
        guard let type = self.symbol.type else { return false }
        guard let terms = self.terms else { return false }
        
        switch (type, terms.count) {
        case (.Negation, 1):
            return terms.first!.isEquationTree
            
        case (.Inequation, 2):
            return terms.first!.isFunctionTree && terms.last!.isFunctionTree
        default:
            return false
        }
    }
    
    /// Costly check if `self` represents an equation.
    ///
    /// - an expression `s = t` is an inequation if `s` and `t` are function terms.
    private var isEquationTree : Bool {
        guard let type = self.symbol.type where type == SymbolType.Equation else { return false }
        guard let terms = self.terms where terms.count == 2 else { return false }
        return terms.first!.isFunctionTree && terms.last!.isFunctionTree
    }
    
    /// Costly check if `self` represents the negation of an atomic formula.
    private var isNegativeLiteralTree : Bool {
        return self.isInequationTree || self.isNegativePredicateTree
    }
    
    /// Costly check if `self` represents an atomic formula.
    private var isPositiveLiteralTree : Bool {
        return self.isEquationTree || self.isPositivePredicateTree
    }
    
    /// Costly check if `self` represents a literal.
    public var isLiteral : Bool {
        return self.isPositiveLiteralTree || self.isNegativeLiteralTree
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
    
}
