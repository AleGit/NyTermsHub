//
//  Node(LaTeX).swift
//  NyTerms
//
//  Created by Alexander Maringele on 17.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Node where Symbol == String {
    
    var laTeXDescription : String {
        return buildDescription ( LaTeX.Symbols.decorate )
        
    }
}
