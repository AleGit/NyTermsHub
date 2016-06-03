//
//  Z3.swift
//  NyTerms
//
//  Created by Alexander Maringele on 03.06.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

struct Z3 {
    
    static var info : String {
        var major:UInt32=0,minor:UInt32=0,build:UInt32=0,revision:UInt32=0
        Z3_get_version(&major, &minor, &build, &revision)
        return "Z3 v\(major).\(minor).\(build).\(revision)"
    }  
    
}
