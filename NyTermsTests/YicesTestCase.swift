//
//  YicesTestCase.swift
//  NyTerms
//
//  Created by Alexander Maringele on 17.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//


import XCTest
@testable import NyTerms


class YicesTestCase : XCTestCase {
    override func setUp() {
        super.setUp()
        yices_init()
        resetGlobalStringSymbols()
    }
    
    override func tearDown() {
        yices_exit()
        super.tearDown()
    }
    
}