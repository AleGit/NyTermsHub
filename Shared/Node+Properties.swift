//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

extension Node {
    
    
    /// Flat check if `self` represents a variable,
    /// i.e. a leaf node without a list of subnodes.
    var isVariable : Bool {
        return self.nodes == nil
    }
    
    /// Flat check if `self` represents a constant (function),
    /// i.e. a node with an empty list of subnodes.
    private var isConstant : Bool {
        guard let nodes = self.nodes else { return false }
        return nodes.count == 0
    }
    
    /// Flat Check if `self` represents a (non-empty) tuple of variables.
    private var isTupleOfVariables : Bool {
        guard self.symbolType == SymbolType.Tuple else { return false }
        guard let nodes = self.nodes else { return false }
        guard nodes.count > 0 else { return false } /* a tuple of variables must not be empty */
        return nodes.reduce(true) { $0 && $1.isVariable }
    }
    
    /// Recursive check if `self` represents a valid rewrite rule, i.e.
    /// an equation that satifies the follwong conditions
    /// - the left-hand side is not a variable
    /// - Vars(right-hand side) is a subset of Vars(left-hand side)
    var isRewriteRule : Bool { // assert only?
        guard self.isEquation else { return false }
        
        // Since self represents a valid equation we know that
        // self has exactly two subnodes and both are valid function nodes
        
        let lhs = self.nodes!.first!
        let rhs = self.nodes!.last!
        
        // We only have to check, that the left-hand side is not a variable
        // and that the right-hand side does not introduce new variables.
        
        guard !lhs.isVariable else { return false }
        guard rhs.allVariables.isSubsetOf(lhs.allVariables) else { return false }
        
        return true
    }
    
    /// Recursive check if `self` represents a valid function term
    ///
    /// - a variable `X` is a (function) term
    /// - a constant `c` is a (function) term
    /// - an expression `f(t_1, ..., t_n)` is a (function) term
    /// if `f` is a function symbol and `t_1`,...,`t_n` are (function) terms.
    /// - an expression `p(t_1, ..., t_n)` is a (predicate) term
    var isTerm : Bool { // Order.swift; assert
        guard let nodes = self.nodes else { return true; } // a variable is a term
        guard let type = self.symbolType else {
            // type is not defined, i.e. symbol is not predefined and not registered
            return nodes.reduce(true) { $0 && $1.isTerm }
        }
        // if the type is defined it must be a function
        return type == SymbolType.Function && nodes.reduce(true) { $0 && $1.isTerm }
    }
    
    /// Recursive check if `self` represents the negation of a valid predicate (term).
    ///
    /// - an expression `~p` is a negated predicate (term), if `p` is a predicate (term).
    private var isNegatedPredicate : Bool {
        guard self.symbolType == SymbolType.Negation else { return false }
        guard let nodes = self.nodes where nodes.count == 1 else { return false }
        
        return nodes.first!.isPredicate
    }
    
    /// Recursive check if `self` represents a valid predicate term.
    ///
    /// - an expression `p(t_1,...t_n)` is a positive predicate term
    /// if `p` is a predicate symbol and `t_1`,...,`t_n` are (function) nodes.
    private var isPredicate : Bool {
        if let type = self.symbolType {
            // if the symbol is defined it must be a predicatate symbol
            guard type == SymbolType.Predicate else { return false }
        }
        guard let nodes = self.nodes else { return false }  // a variable is not a predicate term
        
        return nodes.reduce(true) { $0 && $1.isTerm }
    }
    
    /// Recursive check if `self` represents a valid inequation or the negation of a valid equation.
    ///
    /// - an expression `s ≠ t` is an inequation if `s` and `t` are function terms.
    /// - an expression `~E` is an inequation, if `E` is an equation.
    private var isInequation : Bool {
        guard let type = self.symbolType else { return false }    // an undefined node type cannot be an inequation
        guard let nodes = self.nodes else { return false }  // a variable is not an inequation
        
        switch (type, nodes.count) {
        case (.Negation, 1):
            // the negation of one equation is an inequation
            return nodes.first!.isEquation
            
        case (.Inequation, 2):
            // the inequation of two terms is a inequation
            return nodes.first!.isTerm && nodes.last!.isTerm
        default:
            return false
        }
    }
    
    /// Recursive check if `self` represents an equation.
    ///
    /// - an expression `s = t` is an equation if `s` and `t` are terms (functions, constants, variables).
    ///
    /// `~I` will never be recognized as an equation, even when `I` is an inequation.
    private var isEquation : Bool {
        guard let type = self.symbolType where type == SymbolType.Equation else { return false }
        guard let nodes = self.nodes where nodes.count == 2 else { return false }
        return nodes.first!.isTerm && nodes.last!.isTerm
    }
    
    /// Recursive check if `self` represents the negation of an valid atomic formula.
    private var isNegatedAtom : Bool {
        return self.isInequation || self.isNegatedPredicate
    }
    
    /// Recursive check if `self` represents an atomic formula.
    private var isAtom : Bool {
        return self.isEquation || self.isPredicate
    }
    
    /// Recursive check if `self` represents a literal.
    var isLiteral : Bool {
        return self.isAtom || self.isNegatedAtom
    }
    
    /// Recursive check if `self` is a first order logic formula.
    ///
    /// - a formula is either a literal or a connection of literals
    var isFormula : Bool {
        guard !self.isLiteral else { return true }
        
        guard let quartuple = self.symbolQuadruple()
            where quartuple.category == SymbolCategory.Connective
            else {
                // undefined or non-connective symbol
                return false
        }
        guard let nodes = self.nodes
            where quartuple.arity.contains(nodes.count)
            else {
                // self has wrong number of subnodes
                return false
        }
        
        return nodes.reduce(true) { $0 && $1.isFormula }
    }
    
    /// Recursive check if `self` represents a disjunction of literals,
    /// i.e. nodes are disjunctions or literals.
    private var isDisjunctionOfLiterals : Bool {
        guard !self.isLiteral else {
            // a literal is a disjunction of literals too
            return true
        }
        
        // when the node is not a literal then it must be a disjunction
        guard let type = self.symbolType where type == SymbolType.Disjunction else { return false }
        
        // a disjunction must have a list of subnodes
        guard let nodes = self.nodes else { return false }
        
        // each subnode must be a disjunction of literals
        return nodes.reduce(true) { $0 && $1.isDisjunctionOfLiterals }
    }
    
    /// Recursive check if `self` represents a (flat) disjunction of literals,
    /// i.e. the root node is a disjunction and the subnodes are literals.
    var isClause : Bool {
        guard !self.isLiteral else {
            // a literal is not a clause
            return false
        }
        
        // the root not of a clause must be a disjunction
        guard let type = self.symbolType where type == SymbolType.Disjunction else { return false }
        
        // a disjunction must have a list of subnodes (even if it is empty)
        guard let nodes = self.nodes else { return false }
        
        // each subnode must be a literal (empty clause is possible too)
        return nodes.reduce(true) { $0 && $1.isLiteral }
    }
    
    /// Recursive check if `self` represents as unit clause, i.e. a clause with exactly one literal
    var isUnitClause : Bool {
        
        guard let type = self.symbolType where type == SymbolType.Disjunction else { return false }
        guard let nodes = self.nodes where nodes.count == 1 else { return false }
        
        return nodes.first!.isLiteral
    }
    
    /// Recursive check if `self` represents a Horn clause, i.e. a clause with at most one positive literal.
    var isHornClause : Bool {
        
        guard let type = self.symbolType where type == SymbolType.Disjunction else {
            /* self is not a disjunction, hence self is not a clause */
            assert(false,"not a disjunction, hence not a (horn) clause: \(self)")
            
            return false
        }
        
        // we know: type == SymbolType.Disjunction
        
        guard let nodes = self.nodes else {
            assert(false,"a variable, hence not a (horn) clause: \(self)")
            return false /* nodes are nil, hences self is not a clause */ }
        
        // we know: nodes != nil and we will count the number of positive literals
        
        var numberOfPositiveLiterals = 0
        for node in nodes {
            if node.isNegatedAtom { continue }
            else if node.isAtom {
                numberOfPositiveLiterals += 1
            }
            else {
                assert(false,"not a literal, hence parent is not a (horn) clause: child:\(node) parent:\(self)")
                return false
            }
            
            guard numberOfPositiveLiterals < 2 else { return false }
            
        }
        return true
    }
}
