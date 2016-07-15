//
//  NySequence.swift
//  NyTerms
//
//  Created by Alexander Maringele on 07.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

struct NyGenerator<S,T> : IteratorProtocol {
    private var this : S?
    private let step : (S) -> S?
    private let data : (S) -> T
    
    init(first:S?, step:(S)->S?, data:(S)->T) {
        self.this = first
        self.step = step
        self.data = data
    }
    
    mutating func next() -> T? {
        guard let current = self.this else {
            return nil
        }
        self.this = self.step(current)
        return self.data(current)
    }
}

struct NySequence<S,T> : Sequence {
    private let this : S?
    private let step : (S) -> S?
    private let data : (S) -> T
    
    init(first:S?, step:(S)->S?, data:(S)->T) {
        self.this = first
        self.step = step
        self.data = data
    }
    
    func makeIterator() -> NyGenerator<S,T> {
        return NyGenerator(first: this, step: step, data: data)
    }
    
}
