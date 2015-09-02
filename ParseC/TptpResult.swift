//
//  TptpResult.swift
//  NyTerms
//
//  Created by Alexander Maringele on 16.08.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Cocoa

public final class TptpResult: NSObject {
    public let result: Int
    public let formulae : [TptpFormula]
    public let includes : [TptpInclude]
    
    public init(result:Int, formulae:[TptpFormula], includes : [TptpInclude]) {
        self.result = result
        self.formulae = formulae
        self.includes = includes
    }

}
