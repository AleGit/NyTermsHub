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
        self.fileName = fileName.substringWithRange(fileName.startIndex.successor()..<fileName.endIndex.predecessor())
        self.formulaSelection = formulaSelection;
    }
}

extension TptpInclude {
    override var description : String {
        get {
            guard let selection = formulaSelection else { return "include('\(fileName)')." }
            
            let names = selection.joinWithSeparator(",")
            return "include('\(fileName)',[\(names)])."
                
            
            
        }
    }
}
