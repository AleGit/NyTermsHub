//
//  BuildTriesDemo.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

func buildTriesDemo() {
    
    func execute<T:TrieType where T.Key==SymHop, T.Value==Int>(var trie:T, literals:[TptpNode]) {
        
        let start = CFAbsoluteTimeGetCurrent()
        trie.fill(literals)
        let duration = CFAbsoluteTimeGetCurrent() - start
        print(floor(1_000_000*duration/Double(literals.count)), "µs", trie.dynamicType,literals.count,duration)
    }
    
    
    for name in [ "LCL129-1", "SYN000-2", "PUZ051-1", "HWV074-1", "HWV105-1" ] {
        let literals = TptpNode.literals(name.p)
        
        print("\n",name)
        execute(TailTrie<SymHop,Int>(), literals:literals)
        execute(Trie<SymHop,Int>(), literals:literals)
        
        
        
    }
    
    
    
}

/* 

NyTerms with yices 2.4.1 (x86_64-apple-darwin14.4.0,release,2015-08-10):
/Users/alm/Library/Developer/Xcode/DerivedData/NyTerms-hgbchfqcmrlaxdfodjuqnpiqzqch/Build/Products/Debug/NyTermsCL

LCL129-1
294.0 µs Trie<SymHop, Int> 5 0.00147300958633423
209.0 µs TailTrie<SymHop, Int> 5 0.00104701519012451

SYN000-2
27.0 µs Trie<SymHop, Int> 28 0.000758051872253418
28.0 µs TailTrie<SymHop, Int> 28 0.000789999961853027

PUZ051-1
363.0 µs Trie<SymHop, Int> 84 0.030534029006958
442.0 µs TailTrie<SymHop, Int> 84 0.0371840000152588

HWV074-1
4666.0 µs Trie<SymHop, Int> 6017 28.0810109972954
7944.0 µs TailTrie<SymHop, Int> 6017 47.8007249832153

HWV105-1
561.0 µs Trie<SymHop, Int> 52662 29.5602170228958
1092.0 µs TailTrie<SymHop, Int> 52662 57.5259200334549
Program ended with exit code: 0

*/

/*
NyTerms with yices 2.4.1 (x86_64-apple-darwin14.4.0,release,2015-08-10):
/Users/alm/Library/Developer/Xcode/DerivedData/NyTerms-hgbchfqcmrlaxdfodjuqnpiqzqch/Build/Products/Debug/NyTermsCL

LCL129-1
343.0 µs TailTrie<SymHop, Int> 5 0.00171500444412231
192.0 µs Trie<SymHop, Int> 5 0.000962018966674805

SYN000-2
30.0 µs TailTrie<SymHop, Int> 28 0.000853002071380615
25.0 µs Trie<SymHop, Int> 28 0.00072401762008667

PUZ051-1
394.0 µs TailTrie<SymHop, Int> 84 0.0331739783287048
452.0 µs Trie<SymHop, Int> 84 0.0379839539527893

HWV074-1
7767.0 µs TailTrie<SymHop, Int> 6017 46.7383270263672
4709.0 µs Trie<SymHop, Int> 6017 28.3362950086594

HWV105-1
1066.0 µs TailTrie<SymHop, Int> 52662 56.1873790025711
541.0 µs Trie<SymHop, Int> 52662 28.5403519868851
Program ended with exit code: 0
*/

/*  (without optimized insert for Trie)
NyTerms with yices 2.4.1 (x86_64-apple-darwin14.4.0,release,2015-08-10):
/Users/alm/Library/Developer/Xcode/DerivedData/NyTerms-hgbchfqcmrlaxdfodjuqnpiqzqch/Build/Products/Debug/NyTermsCL

LCL129-1
348.0 µs TailTrie<SymHop, Int> 5 0.00174099206924438
201.0 µs Trie<SymHop, Int> 5 0.00100797414779663

SYN000-2
30.0 µs TailTrie<SymHop, Int> 28 0.000849008560180664
24.0 µs Trie<SymHop, Int> 28 0.000696003437042236

PUZ051-1
392.0 µs TailTrie<SymHop, Int> 84 0.0329380035400391
455.0 µs Trie<SymHop, Int> 84 0.0382260084152222

HWV074-1
7737.0 µs TailTrie<SymHop, Int> 6017 46.5540820360184
4898.0 µs Trie<SymHop, Int> 6017 29.4736059904099

HWV105-1
1110.0 µs TailTrie<SymHop, Int> 52662 58.5058799982071
554.0 µs Trie<SymHop, Int> 52662 29.1821620464325
Program ended with exit code: 0
*/