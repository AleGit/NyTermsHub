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
        
        private static let typeDecorators : [SymbolType:String->String] = [
            
            .LeftParenthesis:{ _ in "(" },
            .RightParenthesis:{ _ in ")" },
            .LeftCurlyBracket:{ _ in "\\{" },
            .RightCurlyBracket:{ _ in "\\}" },
            .LeftSquareBracket:{ _ in "[" },
            .RightSquareBracket:{ _ in "]" },
            .LeftAngleBracket:{ _ in "\\langle" },
            .RightAngleBracket:{ _ in "\\rangle" },
            
            .Negation : { _ in "\\lnot " },
            .Disjunction : { _ in "\\lor " },
            .Conjunction : { _ in "\\land " },
            .Implication : { _ in "\\Rightarrow " },
            .Converse : { _ in "\\Leftarrow " },
            .IFF : { _ in "\\Leftrightarrow " },
            .NIFF: { _ in "\\oplus " },
            .NAND: { _ in "\\uparrow " },
            .NOR: { _ in "\\downarrow " },
            .Sequent: { _ in "\\longrightarrow " },
            .Tuple : { _ in "," },
            
            .Universal : { _ in "\\forall " },
            .Existential : { _ in "\\exists " },
            
            .Equation : { _ in "\\approx " },
            .Inequation : { _ in "\\not\\approx " },
            
            .Predicate : { "{\\mathsf \($0.uppercaseString)}" },
            .Function : { "{\\mathsf \($0)}" },
            .Variable : { $0.lowercaseString }
        ]
        
        static func decorate(symbol:String, type:SymbolType) -> String {
            return LaTeX.Symbols.typeDecorators[type]?(symbol) ?? symbol
        }
    }
    
    
}
