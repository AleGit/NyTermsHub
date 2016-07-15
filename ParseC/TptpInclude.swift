//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

final class TptpInclude: NSObject {
    // TPTP Syntax:
    // <include>            ::= include(<file_name><formula_selection>)
    // <file_name>          ::= <single_quoted>
    // <formula_selection>  ::= ,[<name_list>] | <null>
    
    
    var fileName : String
    let formulaSelection : [String]?
    
    init(fileName: String, formulaSelection : [String]?) {
        assert(!fileName.isEmpty, "<file_name> is empty.")
        assert(fileName.hasPrefix("'") && fileName.hasSuffix("'"), "<file_name> ::= <single_quoted> is not single quoted.")
        
        // store the file name without single quotes:
        self.fileName = fileName.substring(with: fileName.characters.index(after: fileName.startIndex)..<fileName.characters.index(before: fileName.endIndex))
        self.formulaSelection = formulaSelection;
    }
}

extension TptpInclude {
    override var description : String {
        get {
            guard let selection = formulaSelection else { return "include('\(fileName)')." }
            
            let names = selection.joined(separator: ",")
            return "include('\(fileName)',[\(names)])."
                
            
            
        }
    }
}
