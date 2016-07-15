//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

extension TptpRole : CustomStringConvertible, CustomDebugStringConvertible {
    public var description : String {
        switch self {
        case .axiom: return "axiom"
        case .hypothesis: return "hypothesis"
        case .definition: return "definition"
        case .assumption: return "assumption"
        case .lemma: return "lemma"
        case .theorem: return "theorem"
        case .conjecture: return "conjecture"
        case .negatedConjecture: return "negated_conjecture"
        case .plain: return "plain"
        case .fiDomain: return "fi_domain"
        case .fiFunctors: return "fi_functors"
        case .fiPredicates: return "fi_predicates"
        case .dataType: return "type"
        case .unknown: return "unknown"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
    init?(string:String) {
        switch string {
        case "axiom": self = TptpRole.axiom
        case "hypothesis": self = TptpRole.hypothesis
        case "definition": self = TptpRole.definition
        case "assumption": self = TptpRole.assumption
        case "lemma": self = TptpRole.lemma
        case "theorem": self = TptpRole.theorem
        case "conjecture": self = TptpRole.conjecture
        case "negated_conjecture": self = TptpRole.negatedConjecture
        case "plain": self = TptpRole.plain
        case "fi_domain": self = TptpRole.fiDomain
        case "fi_functors": self = TptpRole.fiFunctors
        case "fi_predicates": self = TptpRole.fiPredicates
        case "type": self = TptpRole.dataType
        case "unknown": self = TptpRole.unknown
        default: return nil
        }
    }
}

extension TptpLanguage : CustomStringConvertible, CustomDebugStringConvertible {
    public var description : String {
        switch self {
        case .cnf: return "cnf"
        case .fof: return "fof"
        case .tff: return "tff"
        case .thf: return "thf"
        case .tpi: return "tpi"
        }
    }
  
    public var debugDescription: String {
        return description
    }
    
    init?(string:String) {
        switch string {
        case "cnf": self = TptpLanguage.cnf
        case "fof": self = TptpLanguage.fof
        case "tff": self = TptpLanguage.tff
        case "thf": self = TptpLanguage.thf
        case "tpi": self = TptpLanguage.tpi
        default: return nil
        }
    }
}
