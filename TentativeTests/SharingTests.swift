//
//  SharingTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 21.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest

private protocol Uniqueness {
    static func insert(_ element:Self) -> Self
    
    init (symbol:String, children: [Self]?)
}

extension Uniqueness {
    init(symbol:String) {
        self.init(symbol:symbol, children:nil)
        self = Self.insert(self)
        // this works even for classes
        // despite the fact that we can't do this in classes:
        // self is immutable in classes
        
        
    }
}



final class Unique : Uniqueness {
    
    static var repository = Set<Unique>(minimumCapacity: 32000)
    static func insert(_ element: Unique) -> Unique {
        if let index = Unique.repository.index(of: element) {
            return Unique.repository[index]
        }
        Unique.repository.insert(element)
        return element
    }
    
    private(set) var symbol : String
    private(set) var children : [Unique]?
    
    private init(symbol:String, children:[Unique]?) {
        self.symbol = symbol
        self.children = children
    }
}

extension Unique : CustomStringConvertible {
    var description : String {
        guard let childs = self.children else {
            return "\(symbol)"
        }
        
        let array = childs.map { $0.description }
        let arguments = array.joined(separator: ",")
        return "\(self.symbol)[\(arguments)]"
    }
}

extension Unique : Hashable {
    var hashValue : Int {
        return self.description.hashValue
    }
}

func ==(lhs:Unique,rhs:Unique) -> Bool {
    return (lhs === rhs) || lhs.description == rhs.description
}



class SharingTests: XCTestCase {
    
    func testSharing() {
        var repository = Set<Unique>()
        
        let x0 = Unique(symbol: "X")
        repository.insert(x0)
        
        let x1 = Unique(symbol: "X")
        repository.insert(x1)
        
        
        
        XCTAssertEqual(x0.description,x1.description)
        XCTAssertEqual(x0,x1)
        
        XCTAssertEqual(x0.hashValue,x1.hashValue)
        
        XCTAssertTrue(x1 === x0)
        
        if let index = repository.index(of: x1) {
            let x2 = repository[index]
            
            XCTAssertTrue(x0 === x2)
        }
        else {
            XCTFail()
        }
    }
    
}
