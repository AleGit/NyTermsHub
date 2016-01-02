//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

extension TptpRole : CustomStringConvertible, CustomDebugStringConvertible {
    public var description : String {
        switch self {
        case .Axiom: return "axiom"
        case .Hypothesis: return "hypothesis"
        case .Definition: return "definition"
        case .Assumption: return "assumption"
        case .Lemma: return "lemma"
        case .Theorem: return "theorem"
        case .Conjecture: return "conjecture"
        case .NegatedConjecture: return "negated_conjecture"
        case .Plain: return "plain"
        case .FiDomain: return "fi_domain"
        case .FiFunctors: return "fi_functors"
        case .FiPredicates: return "fi_predicates"
        case .DataType: return "type"
        case .Unknown: return "unknown"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
    init?(string:String) {
        switch string {
        case "axiom": self = TptpRole.Axiom
        case "hypothesis": self = TptpRole.Hypothesis
        case "definition": self = TptpRole.Definition
        case "assumption": self = TptpRole.Assumption
        case "lemma": self = TptpRole.Lemma
        case "theorem": self = TptpRole.Theorem
        case "conjecture": self = TptpRole.Conjecture
        case "negated_conjecture": self = TptpRole.NegatedConjecture
        case "plain": self = TptpRole.Plain
        case "fi_domain": self = TptpRole.FiDomain
        case "fi_functors": self = TptpRole.FiFunctors
        case "fi_predicates": self = TptpRole.FiPredicates
        case "type": self = TptpRole.DataType
        case "unknown": self = TptpRole.Unknown
        default: return nil
        }
    }
}

extension TptpLanguage : CustomStringConvertible, CustomDebugStringConvertible {
    public var description : String {
        switch self {
        case .CNF: return "cnf"
        case .FOF: return "fof"
        case .TFF: return "tff"
        case .THF: return "thf"
        case .TPI: return "tpi"
        }
    }
  
    public var debugDescription: String {
        return description
    }
    
    init?(string:String) {
        switch string {
        case "cnf": self = TptpLanguage.CNF
        case "fof": self = TptpLanguage.FOF
        case "tff": self = TptpLanguage.TFF
        case "thf": self = TptpLanguage.THF
        case "tpi": self = TptpLanguage.TPI
        default: return nil
        }
    }
}