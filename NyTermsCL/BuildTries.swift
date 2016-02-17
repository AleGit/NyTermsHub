//
//  BuildTriesDemo.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

struct BuildTries {
    
    static func demo() {
        
        func execute<T:TrieType where T.Key==SymHop, T.Value==Int>(var trie:T, literals:[TptpNode]) {
            let (_,duration) = measure {
                trie.fill(literals)
            }
            print(duration.timeIntervalDescriptionMarkedWithUnits, trie.dynamicType,literals.count,duration)
        }
        
        func preorder<T:TrieType where T.Key==String, T.Value==Int>(var trie:T, literals:[TptpNode]) {
            
            let (_,duration) = measure {
                trie.fillPreorder(literals)
            }
            print(duration.timeIntervalDescriptionMarkedWithUnits, trie.dynamicType,literals.count,duration)
        }
        
        for name in [ "LCL129-1", "SYN000-2", "PUZ051-1", "HWV074-1", "HWV105-1" ] {
            let path = name.p
            let (literals, duration) = measure {
                TptpNode.literals(path)
            }
            
            print("")
            print(name, literals.count,"literals read in",
                duration.timeIntervalDescriptionMarkedWithUnits, "from",path)
            
            execute(TailTrie<SymHop,Int>(), literals:literals)
            execute(Trie<SymHop,Int>(), literals:literals)
            preorder(Trie<String,Int>(), literals:literals)
        }
    }
}

/*

========================= 2016-02-17 07:51:20 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
TPTP_ROOT /Users/Shared/TPTP

LCL129-1
1ms 726µs TailTrie<SymHop, Int> 5 0.00172603130340576
1ms 55µs Trie<SymHop, Int> 5 0.00105500221252441
298µs 977ns Trie<String, Int> 5 0.000298976898193359

SYN000-2
837µs 28ns TailTrie<SymHop, Int> 28 0.000837028026580811
697µs 17ns Trie<SymHop, Int> 28 0.000697016716003418
428µs 21ns Trie<String, Int> 28 0.00042802095413208

PUZ051-1
44ms 539µs TailTrie<SymHop, Int> 84 0.0445389747619629
32ms 819µs Trie<SymHop, Int> 84 0.0328189730644226
16ms 568µs Trie<String, Int> 84 0.0165680050849915

HWV074-1
46s 395ms TailTrie<SymHop, Int> 6017 46.3949609994888
31s 620ms Trie<SymHop, Int> 6017 31.6202830076218
1s 930ms Trie<String, Int> 6017 1.93041801452637

HWV105-1
1m 5s TailTrie<SymHop, Int> 52662 65.1866880059242
29s 182ms Trie<SymHop, Int> 52662 29.182313978672
16s 374ms Trie<String, Int> 52662 16.3743050098419
========================= ========================= =========================
========================= 2016-02-17 07:54:33 +0000 =========================

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