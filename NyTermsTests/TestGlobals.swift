//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation
@testable
import NyTerms

typealias TestNode = NodeStruct

// predefined test terms

let a = TestNode(stringLiteral:"a")
let b = TestNode(stringLiteral:"b")
let c = TestNode(stringLiteral:"c")
let cbot = TestNode(stringLiteral:"⊥")
let x = TestNode(stringLiteral:"X")
let y = TestNode(stringLiteral:"Y")
let z = TestNode(stringLiteral:"Z")
let fxy = TestNode(symbol:"f", nodes: [x,y])
let fax = fxy * [x:a,y:x]
let fxa = fxy * [y:a]
let faa = fxy * [x:a,y:a]
let gx = TestNode(symbol:"g", nodes: [x])
let gb = gx * [x:b]
let gfaa = TestNode(function:"g",nodes: [faa])

// rules

let fxy_x = TestNode.Rule(fxy,x)
