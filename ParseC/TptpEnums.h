//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef Tptp_Enums_h
#define Tptp_Enums_h

#pragma mark - enums

/// <annotated_formula>  ::= <cnf_annotated> | <fof_annotated> | ...
typedef NS_ENUM(NSInteger, TptpLanguage) {
    /// A clause, i.e. a disjunctions of literals.
    TptpLanguageCNF,
    /// An arbitrary first order root.
    TptpLanguageFOF,
    
    TptpLanguageTPI,
    TptpLanguageTHF,
    TptpLanguageTFF
};

/// <formula_role> ::= <lower_word>
typedef NS_ENUM(NSInteger, TptpRole) {
    /// "axiom"s are accepted, without proof. There is no guarantee that the axioms of a problem are consistent.
    TptpRoleAxiom,
    /// "hypothesis"s are assumed to be true for a particular problem, and are used like "axiom"s.
    TptpRoleHypothesis,
    /// "definition"s are intended to define symbols. They are either universally quantified equations,
    /// or universally quantified equivalences with an atomic lefthand side. They can be treated like "axiom"s.
    TptpRoleDefinition,
    /// "assumption"s can be used like axioms, but must be discharged before a derivation is complete.
    TptpRoleAssumption,
    /// "lemma"s and "theorem"s have been proven from the "axiom"s. They can be
    /// used like "axiom"s in problems, and a problem containing a non-redundant
    /// "lemma" or theorem" is ill-formed. They can also appear in derivations.
    TptpRoleLemma,
    /// "theorem"s are more important than "lemma"s from the user perspective.
    TptpRoleTheorem,
    /// "conjecture"s are to be proven from the "axiom"(-like) formulae. A problem
    /// is solved only when all "conjecture"s are proven.
    TptpRoleConjecture,
    /// "negated_conjecture"s are formed from negation of a "conjecture" (usually in a FOF to CNF conversion).
    TptpRoleNegatedConjecture,
    /// "plain"s have no specified user semantics.
    TptpRolePlain,
    /// "fi_domain", "fi_functors", and "fi_predicates" are used to record the
    /// domain, interpretation of functors, and interpretation of predicates, for
    /// a finite interpretation.
    TptpRoleFiDomain,
    TptpRoleFiFunctors,
    TptpRoleFiPredicates,
    /// "type" defines the type globally for one symbol; treat as $true.
    TptpRoleDataType,
    /// "unknown"s have unknown role, and this is an error situation.
    TptpRoleUnknown
};

#endif
