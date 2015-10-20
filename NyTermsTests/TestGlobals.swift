//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation
import NyTerms

typealias TestNode = NodeStruct

// terms

let a = TestNode(constant:"a")
let b = TestNode(constant:"b")
let c = TestNode(constant:"c")
let cbot = TestNode(constant:"⊥")
let x = TestNode(variable:"X")
let y = TestNode(variable:"Y")
let z = TestNode(variable:"Z")
let fxy = TestNode(function:"f", terms: [x,y])
let fax = fxy * [x:a,y:x]
let fxa = fxy * [y:a]
let faa = fxy * [x:a,y:a]
let gx = TestNode(function:"g", terms: [x])
let gb = gx * [x:b]
let gfaa = TestNode(function:"g",terms: [faa])

// rules

let fxy_x = TestNode.Rule(fxy,x)