//
//  LaTeX+Symbols.swift
//  NyTerms
//
//  Created by Alexander Maringele on 30.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

struct LaTeX {
    struct Symbols {
        
        private static let typeDecorators : [SymbolType:(String)->String] = [
            
            .leftParenthesis:{ _ in "(" },
            .rightParenthesis:{ _ in ")" },
            .leftCurlyBracket:{ _ in "\\{" },
            .rightCurlyBracket:{ _ in "\\}" },
            .leftSquareBracket:{ _ in "[" },
            .rightSquareBracket:{ _ in "]" },
            .leftAngleBracket:{ _ in "\\langle" },
            .rightAngleBracket:{ _ in "\\rangle" },
            
            .negation : { _ in "\\lnot " },
            .disjunction : { _ in "\\lor " },
            .conjunction : { _ in "\\land " },
            .implication : { _ in "\\Rightarrow " },
            .converse : { _ in "\\Leftarrow " },
            .iff : { _ in "\\Leftrightarrow " },
            .niff: { _ in "\\oplus " },
            .nand: { _ in "\\uparrow " },
            .nor: { _ in "\\downarrow " },
            .sequent: { _ in "\\longrightarrow " },
            .tuple : { _ in "," },
            
            .universal : { _ in "\\forall " },
            .existential : { _ in "\\exists " },
            
            .equation : { _ in "\\approx " },
            .inequation : { _ in "\\not\\approx " },
            
            .predicate : { "{\\mathsf \($0.uppercased())}" },
            .function : { "{\\mathsf \($0)}" },
            .variable : { $0.lowercased() }
        ]
        
        static func decorate(_ symbol:String, type:SymbolType) -> String {
            return LaTeX.Symbols.typeDecorators[type]?(symbol) ?? symbol
        }
    }
    
    
}
