//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation
import NyTerms

typealias TestTerm = TermSampleStruct

// terms

let a = TestTerm(constant:"a")
let b = TestTerm(constant:"b")
let c = TestTerm(constant:"c")
let cbot = TestTerm(constant:"⊥")
let x = TestTerm(variable:"X")
let y = TestTerm(variable:"Y")
let z = TestTerm(variable:"Z")
let fxy = TestTerm(function:"f", terms: [x,y])
let fax = fxy * [x:a,y:x]
let fxa = fxy * [y:a]
let faa = fxy * [x:a,y:a]
let gx = TestTerm(function:"g", terms: [x])
let gb = gx * [x:b]

// rules

let fxy_x = TestTerm.Rule(fxy,x)