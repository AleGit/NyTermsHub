//
//  BuildTriesDemo.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

struct DemoTrieBuild {
    
    static private func execute<T:TrieType where T.Value==Int>(
        var trie:T, literals:[TptpNode], f:(TptpNode)->Array<[T.Key]>) {
            
            let (_,duration) = measure {
                trie.fill(literals) { f($0) }
            }
            
            print(duration.prettyTimeIntervalDescription, T.self, literals.count, duration)
    }
    
    static private func execute<T:TrieType where T.Value==Int>(
        var trie:T, message:String? = nil, literals:[TptpNode], f:(TptpNode)->[T.Key]) {
            let (_,duration) = measure {
                trie.fill(literals) { f($0) }
            }
            
            print(duration.prettyTimeIntervalDescription, T.self, literals.count, duration)
    }
    
    static func demo134() {
        print(self.self,"\(__FUNCTION__)\n")
        
        let name = "HWV134-1"
        let path = name.p! // file must be accessible
        let (literals, duration) = measure {
            TptpNode.literals(path)
        }
        
        print(name, literals.count,"literals read in",duration.prettyTimeIntervalDescription, "from",path)
        
        print("* Term Paths *")
        
        execute(TrieClass<SymHop<String>,Int>(), literals:literals) { $0.paths }
        
        print("* Discrimination Tree *")
        
        execute(TrieClass<String,Int>(), literals:literals) { $0.preorderPath }
        
        print("")
    }
    
    static func demo() {
        print(self.self,"\(__FUNCTION__)\n")
        for name in [ "LCL129-1", "SYN000-2", "PUZ051-1",
            // "HWV074-1", "HWV105-1"
            ] {
                guard let path = name.p else {
                    print("\(name) skipped ...")
                    continue
                }
                
                print("Processing \(name) ...")
                let (literals, duration) = measure {
                    TptpNode.literals(path)
                }
                print(name, literals.count,"literals read in", duration.prettyTimeIntervalDescription, "from",path)
                print("* Term Paths *")
                
                execute(TailTrie<SymHop<String>,Int>(), literals:literals) { $0.paths }
                execute(TailTrie<String,Int>(), literals:literals) { $0.stringPaths }
                execute(TrieStruct<SymHop<String>,Int>(), literals:literals) { $0.paths }
                execute(TrieStruct<String,Int>(), literals:literals) { $0.stringPaths }
                execute(TrieClass<SymHop<String>,Int>(), literals:literals) { $0.paths }
                execute(TrieClass<String,Int>(), literals:literals) { $0.stringPaths }
                
                print("* Discrimination Trees *")
                execute(TrieStruct<String,Int>(), literals:literals) { [$0.preorderPath] }
                execute(TrieStruct<String,Int>(), literals:literals) { $0.preorderPath }
                execute(TrieClass<String,Int>(), literals:literals) { $0.preorderPath }
                
                print("")
                
        }
    }
}
/* *** Mac Mini ********* ************************* *************************
========================= 2016-02-25 06:52:03 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
neither argument -tptp_root nor environment variable TPTP_ROOT were set /Users/Shared/TPTP
TPTP_ROOT /Users/Shared/TPTP

LCL129-1 5 literals read in 589µs 13ns from /Users/Shared/TPTP/Problems/LCL/LCL129-1.p
Term Paths
926µs 971ns TailTrie<SymHop, Int>   5 0.000926971435546875
846µs 982ns TailTrie<String, Int>   5 0.000846982002258301
595µs 987ns TrieStruct<SymHop, Int> 5 0.000595986843109131
612µs  20ns TrieStruct<String, Int> 5 0.000612020492553711
424µs 981ns TrieClass<SymHop,Int>   5 0.000424981117248535
498µs 056ns TrieClass<Symbol,Int>   5 0.000498056411743164
Discrimination Tree
173µs 986ns TrieStruct<String, Int> 5 0.000173985958099365
273µs 049ns TrieStruct<String, Int> 5 0.000273048877716064
117µs 004ns TrieClass<Symbol,Int>   5 0.000117003917694092

SYN000-2 28 literals read in 826µs 1ns from /Users/Shared/TPTP/Problems/SYN/SYN000-2.p
Term Paths
496µs 984ns TailTrie<SymHop, Int>   28 0.000496983528137207
595µs 987ns TailTrie<String, Int>   28 0.000595986843109131
401µs 020ns TrieStruct<SymHop, Int> 28 0.000401020050048828
371µs 993ns TrieStruct<String, Int> 28 0.000371992588043213
295µs 997ns TrieClass<SymHop,Int>   28 0.00029599666595459
303µs 984ns TrieClass<Symbol,Int>   28 0.000303983688354492
Discrimination Tree
365µs 973ns TrieStruct<String, Int> 28 0.000365972518920898
284µs 016ns TrieStruct<String, Int> 28 0.000284016132354736
211µs 000ns TrieClass<Symbol,Int>   28 0.000211000442504883

PUZ051-1 84 literals read in 2ms 690µs from /Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p
Term Paths
19ms 392µs TailTrie<SymHop, Int> 84 0.0193919539451599
23ms 212µs TailTrie<String, Int> 84 0.0232120156288147
20ms 887µs TrieStruct<SymHop, Int> 84 0.020887017250061
25ms 295µs TrieStruct<String, Int> 84 0.0252950191497803
12ms 136µs TrieClass<SymHop,Int> 84 0.0121360421180725
13ms 731µs TrieClass<Symbol,Int> 84 0.0137310028076172
Discrimination Tree
5ms 687µs TrieStruct<String, Int> 84 0.00568699836730957
5ms 19µs TrieStruct<String, Int> 84 0.00501900911331177
4ms 228µs TrieClass<Symbol,Int> 84 0.00422799587249756

HWV074-1 6017 literals read in 259ms 602µs from /Users/Shared/TPTP/Problems/HWV/HWV074-1.p
Term Paths
27s 212ms TailTrie<SymHop, Int> 6017 27.2115629911423
26s 656ms TailTrie<String, Int> 6017 26.6564700007439
16s 277ms TrieStruct<SymHop, Int> 6017 16.2767710089684
16s 671ms TrieStruct<String, Int> 6017 16.6711930036545
2s 40ms TrieClass<SymHop,Int> 6017 2.04003202915192
2s 427ms TrieClass<Symbol,Int> 6017 2.42656600475311
Discrimination Tree
1s 86ms TrieStruct<String, Int> 6017 1.08593201637268
1s 86ms TrieStruct<String, Int> 6017 1.08583998680115
576ms 620µs TrieClass<Symbol,Int> 6017 0.576620042324066

HWV105-1 52662 literals read in 437ms 146µs from /Users/Shared/TPTP/Problems/HWV/HWV105-1.p
Term Paths
34s 7ms TailTrie<SymHop, Int> 52662 34.0068619847298
32s 309ms TailTrie<String, Int> 52662 32.3093590140343
16s 122ms TrieStruct<SymHop, Int> 52662 16.1216639876366
15s 953ms TrieStruct<String, Int> 52662 15.9525089859962
990ms 843µs TrieClass<SymHop,Int> 52662 0.990842998027802
1s 159ms TrieClass<Symbol,Int> 52662 1.15927797555923
Discrimination Tree
9s 156ms TrieStruct<String, Int> 52662 9.15601998567581
9s 0ms TrieStruct<String, Int> 52662 9.00028401613235
568ms 302µs TrieClass<Symbol,Int> 52662 0.568301975727081
========================= ========================= =========================
========================= 2016-02-25 06:55:40 +0000 =========================
Program ended with exit code: 0
*/
/* *** iMac *** ********* ************************* *************************
========================= 2016-02-22 13:27:04 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
TPTP_ROOT /Users/Shared/TPTP

LCL129-1 5 literals read in 2ms 714µs from /Users/Shared/TPTP/Problems/LCL/LCL129-1.p
Term Paths
1ms 584µs TailTrie<SymHop, Int> 5 0.00158399343490601
1ms 362µs TailTrie<String, Int> 5 0.00136202573776245
1ms 40µs TrieStruct<SymHop, Int> 5 0.00104004144668579
1ms 140µs TrieStruct<String, Int> 5 0.00113999843597412
759µs 6ns TrieClass<SymHop,Int> 5 0.000759005546569824
965µs 953ns TrieClass<Symbol,Int> 5 0.00096595287322998
Discrimination Tree
527µs 978ns TrieStruct<String, Int> 5 0.00052797794342041
320µs 17ns TrieStruct<String, Int> 5 0.000320017337799072
313µs 997ns TrieClass<Symbol,Int> 5 0.000313997268676758

SYN000-2 28 literals read in 2ms 138µs from /Users/Shared/TPTP/Problems/SYN/SYN000-2.p
Term Paths
880µs 3ns TailTrie<SymHop, Int> 28 0.000880002975463867
829µs 995ns TailTrie<String, Int> 28 0.000829994678497314
698µs 30ns TrieStruct<SymHop, Int> 28 0.0006980299949646
1ms 424µs TrieStruct<String, Int> 28 0.00142401456832886
720µs 978ns TrieClass<SymHop,Int> 28 0.000720977783203125
729µs 24ns TrieClass<Symbol,Int> 28 0.000729024410247803
Discrimination Tree
521µs 4ns TrieStruct<String, Int> 28 0.000521004199981689
499µs 964ns TrieStruct<String, Int> 28 0.000499963760375977
427µs 8ns TrieClass<Symbol,Int> 28 0.000427007675170898

PUZ051-1 84 literals read in 4ms 192µs from /Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p
Term Paths
40ms 412µs TailTrie<SymHop, Int> 84 0.0404119491577148
43ms 451µs TailTrie<String, Int> 84 0.0434510111808777
36ms 212µs TrieStruct<SymHop, Int> 84 0.0362120270729065
40ms 459µs TrieStruct<String, Int> 84 0.0404589772224426
20ms 421µs TrieClass<SymHop,Int> 84 0.020421028137207
30ms 926µs TrieClass<Symbol,Int> 84 0.030925989151001
Discrimination Tree
8ms 678µs TrieStruct<String, Int> 84 0.00867801904678345
8ms 320µs TrieStruct<String, Int> 84 0.00831997394561768
9ms 511µs TrieClass<Symbol,Int> 84 0.00951099395751953

HWV074-1 6017 literals read in 412ms 312µs from /Users/Shared/TPTP/Problems/HWV/HWV074-1.p
Term Paths
46s 338ms TailTrie<SymHop, Int> 6017 46.3377429842949
47s 669ms TailTrie<String, Int> 6017 47.6687960028648
28s 794ms TrieStruct<SymHop, Int> 6017 28.7935120463371
30s 0ms TrieStruct<String, Int> 6017 30.0004360079765
3s 410ms TrieClass<SymHop,Int> 6017 3.41026902198792
4s 297ms TrieClass<Symbol,Int> 6017 4.29727798700333
Discrimination Tree
1s 841ms TrieStruct<String, Int> 6017 1.84086298942566
1s 837ms TrieStruct<String, Int> 6017 1.83684599399567
970ms 68µs TrieClass<Symbol,Int> 6017 0.970068037509918

HWV105-1 52662 literals read in 653ms 781µs from /Users/Shared/TPTP/Problems/HWV/HWV105-1.p
Term Paths
58s 100ms TailTrie<SymHop, Int> 52662 58.0997920036316
55s 876ms TailTrie<String, Int> 52662 55.8761669993401
28s 267ms TrieStruct<SymHop, Int> 52662 28.2672550082207
28s 396ms TrieStruct<String, Int> 52662 28.3957919478416
1s 643ms TrieClass<SymHop,Int> 52662 1.64326798915863
1s 965ms TrieClass<Symbol,Int> 52662 1.96546697616577
Discrimination Tree
16s 124ms TrieStruct<String, Int> 52662 16.1242799758911
15s 998ms TrieStruct<String, Int> 52662 15.9975399971008
951ms 864µs TrieClass<Symbol,Int> 52662 0.951864004135132
========================= ========================= =========================
========================= 2016-02-22 13:33:21 +0000 =========================
Program ended with exit code: 0

========================= 2016-02-22 09:38:03 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
TPTP_ROOT /Users/Shared/TPTP

LCL129-1 5 literals read in 615µs 1ns from /Users/Shared/TPTP/Problems/LCL/LCL129-1.p
Term Paths
1ms 300µs TailTrie<SymHop, Int> 5 0.00130003690719604
1ms 359µs TailTrie<String, Int> 5 0.00135898590087891
936µs 31ns TrieStruct<SymHop, Int> 5 0.000936031341552734
1ms 112µs TrieStruct<String, Int> 5 0.00111198425292969
768µs 960ns TrieClass<SymHop,Int> 5 0.000768959522247314
919µs 998ns TrieClass<Symbol,Int> 5 0.000919997692108154
Discrimination Tree
351µs 12ns TrieStruct<String, Int> 5 0.000351011753082275
316µs 978ns TrieStruct<String, Int> 5 0.000316977500915527
420µs 988ns TrieClass<Symbol,Int> 5 0.000420987606048584

SYN000-2 28 literals read in 1ms 76µs from /Users/Shared/TPTP/Problems/SYN/SYN000-2.p
Term Paths
917µs 971ns TailTrie<SymHop, Int> 28 0.000917971134185791
831µs 962ns TailTrie<String, Int> 28 0.000831961631774902
721µs 991ns TrieStruct<SymHop, Int> 28 0.000721991062164307
753µs 999ns TrieStruct<String, Int> 28 0.000753998756408691
589µs 967ns TrieClass<SymHop,Int> 28 0.000589966773986816
645µs 995ns TrieClass<Symbol,Int> 28 0.000645995140075684
Discrimination Tree
449µs 2ns TrieStruct<String, Int> 28 0.000449001789093018
680µs 983ns TrieStruct<String, Int> 28 0.000680983066558838
531µs 18ns TrieClass<Symbol,Int> 28 0.000531017780303955

PUZ051-1 84 literals read in 3ms 999µs from /Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p
Term Paths
38ms 280µs TailTrie<SymHop, Int> 84 0.0382800102233887
50ms 745µs TailTrie<String, Int> 84 0.0507450103759766
32ms 13µs TrieStruct<SymHop, Int> 84 0.0320129990577698
54ms 414µs TrieStruct<String, Int> 84 0.0544140338897705
20ms 198µs TrieClass<SymHop,Int> 84 0.0201979875564575
25ms 504µs TrieClass<Symbol,Int> 84 0.0255039930343628
Discrimination Tree
9ms 992µs TrieStruct<String, Int> 84 0.00999200344085693
10ms 229µs TrieStruct<String, Int> 84 0.0102289915084839
7ms 261µs TrieClass<Symbol,Int> 84 0.00726097822189331

HWV074-1 6017 literals read in 375ms 650µs from /Users/Shared/TPTP/Problems/HWV/HWV074-1.p
Term Paths
46s 278ms TailTrie<SymHop, Int> 6017 46.2779850363731
1m 1s TailTrie<String, Int> 6017 61.4154630303383
35s 387ms TrieStruct<SymHop, Int> 6017 35.3867089748383
35s 991ms TrieStruct<String, Int> 6017 35.9908230304718
3s 406ms TrieClass<SymHop,Int> 6017 3.40615302324295
4s 282ms TrieClass<Symbol,Int> 6017 4.28221499919891
Discrimination Tree
1s 854ms TrieStruct<String, Int> 6017 1.85435199737549
1s 870ms TrieStruct<String, Int> 6017 1.86960101127625
978ms 561µs TrieClass<Symbol,Int> 6017 0.978560984134674

HWV105-1 52662 literals read in 658ms 247µs from /Users/Shared/TPTP/Problems/HWV/HWV105-1.p
Term Paths
58s 296ms TailTrie<SymHop, Int> 52662 58.295657992363
1m 1s TailTrie<String, Int> 52662 60.7028260231018
30s 348ms TrieStruct<SymHop, Int> 52662 30.3479439616203
30s 541ms TrieStruct<String, Int> 52662 30.5408920049667
1s 660ms TrieClass<SymHop,Int> 52662 1.65990298986435
1s 958ms TrieClass<Symbol,Int> 52662 1.9579850435257
Discrimination Tree
16s 489ms TrieStruct<String, Int> 52662 16.4887549877167
16s 254ms TrieStruct<String, Int> 52662 16.2544739842415
949ms 660µs TrieClass<Symbol,Int> 52662 0.949660003185272
========================= ========================= =========================
========================= 2016-02-22 09:44:56 +0000 =========================
Program ended with exit code: 0

========================= 2016-02-17 11:52:29 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
TPTP_ROOT /Users/Shared/TPTP

LCL129-1 5 literals read in 2ms 149µs from /Users/Shared/TPTP/Problems/LCL/LCL129-1.p
Term Paths
1ms 616µs TailTrie<SymHop, Int> 5 0.00161600112915039
2ms 975µs TailTrie<String, Int> 5 0.00297504663467407
1ms 12µs TrieStruct<SymHop, Int> 5 0.00101202726364136
1ms 108µs TrieStruct<String, Int> 5 0.00110799074172974
Discrimination Tree
321µs 31ns TrieStruct<String, Int> 5 0.000321030616760254
218µs 987ns TrieStruct<String, Int> 5 0.000218987464904785

SYN000-2 28 literals read in 1ms 273µs from /Users/Shared/TPTP/Problems/SYN/SYN000-2.p
Term Paths
707µs 984ns TailTrie<SymHop, Int> 28 0.00070798397064209
756µs 979ns TailTrie<String, Int> 28 0.000756978988647461
609µs 40ns TrieStruct<SymHop, Int> 28 0.000609040260314941
653µs 28ns TrieStruct<String, Int> 28 0.00065302848815918
Discrimination Tree
440µs 1ns TrieStruct<String, Int> 28 0.000440001487731934
421µs 47ns TrieStruct<String, Int> 28 0.000421047210693359

PUZ051-1 84 literals read in 4ms 937µs from /Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p
Term Paths
40ms 303µs TailTrie<SymHop, Int> 84 0.0403029918670654
43ms 898µs TailTrie<String, Int> 84 0.0438979864120483
40ms 485µs TrieStruct<SymHop, Int> 84 0.0404850244522095
53ms 513µs TrieStruct<String, Int> 84 0.0535129904747009
Discrimination Tree
14ms 233µs TrieStruct<String, Int> 84 0.0142329931259155
10ms 84µs TrieStruct<String, Int> 84 0.0100839734077454

HWV074-1 6017 literals read in 394ms 110µs from /Users/Shared/TPTP/Problems/HWV/HWV074-1.p
Term Paths
1m 2s TailTrie<SymHop, Int> 6017 61.5492870211601
1m 7s TailTrie<String, Int> 6017 67.1801300048828
39s 450ms TrieStruct<SymHop, Int> 6017 39.4499650001526
47s 997ms TrieStruct<String, Int> 6017 47.9972169995308
Discrimination Tree
3s 619ms TrieStruct<String, Int> 6017 3.61944401264191
3s 826ms TrieStruct<String, Int> 6017 3.82632201910019

HWV105-1 52662 literals read in 1s 418ms from /Users/Shared/TPTP/Problems/HWV/HWV105-1.p
Term Paths
2m 4s TailTrie<SymHop, Int> 52662 124.100395023823
1m 38s TailTrie<String, Int> 52662 98.4727579951286
36s 419ms TrieStruct<SymHop, Int> 52662 36.4185609817505
38s 650ms TrieStruct<String, Int> 52662 38.6495990157127
Discrimination Tree
20s 633ms TrieStruct<String, Int> 52662 20.6329929828644
20s 933ms TrieStruct<String, Int> 52662 20.9329180121422
========================= ========================= =========================
========================= 2016-02-17 12:01:58 +0000 =========================

========================= 2016-02-17 11:23:59 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
TPTP_ROOT /Users/Shared/TPTP

LCL129-1 5 literals read in 856µs 42ns from /Users/Shared/TPTP/Problems/LCL/LCL129-1.p
1ms 770µs TailTrie<SymHop, Int> 5 0.00177001953125
1ms 314µs TailTrie<String, Int> 5 0.00131404399871826
1ms 73µs TrieStruct<SymHop, Int> 5 0.00107300281524658
1ms 390µs TrieStruct<String, Int> 5 0.00139003992080688
364µs 959ns TrieStruct<String, Int> 5 0.000364959239959717
310µs 4ns TrieStruct<String, Int> 5 0.000310003757476807

SYN000-2 28 literals read in 1ms 290µs from /Users/Shared/TPTP/Problems/SYN/SYN000-2.p
914µs 37ns TailTrie<SymHop, Int> 28 0.000914037227630615
948µs 12ns TailTrie<String, Int> 28 0.000948011875152588
698µs 30ns TrieStruct<SymHop, Int> 28 0.0006980299949646
753µs 999ns TrieStruct<String, Int> 28 0.000753998756408691
526µs 11ns TrieStruct<String, Int> 28 0.000526010990142822
627µs 995ns TrieStruct<String, Int> 28 0.000627994537353516

PUZ051-1 84 literals read in 3ms 958µs from /Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p
36ms 493µs TailTrie<SymHop, Int> 84 0.0364930033683777
42ms 698µs TailTrie<String, Int> 84 0.0426980257034302
40ms 987µs TrieStruct<SymHop, Int> 84 0.0409870147705078
38ms 800µs TrieStruct<String, Int> 84 0.0388000011444092
8ms 660µs TrieStruct<String, Int> 84 0.00866001844406128
8ms 632µs TrieStruct<String, Int> 84 0.00863200426101685

HWV074-1 6017 literals read in 387ms 168µs from /Users/Shared/TPTP/Problems/HWV/HWV074-1.p
46s 738ms TailTrie<SymHop, Int> 6017 46.7380290031433
48s 408ms TailTrie<String, Int> 6017 48.4083880186081
28s 687ms TrieStruct<SymHop, Int> 6017 28.6866199970245
29s 724ms TrieStruct<String, Int> 6017 29.724130988121
1s 811ms TrieStruct<String, Int> 6017 1.81139302253723
1s 801ms TrieStruct<String, Int> 6017 1.8007670044899

HWV105-1 52662 literals read in 619ms 586µs from /Users/Shared/TPTP/Problems/HWV/HWV105-1.p
56s 425ms TailTrie<SymHop, Int> 52662 56.4249269962311
56s 320ms TailTrie<String, Int> 52662 56.3197460174561
28s 214ms TrieStruct<SymHop, Int> 52662 28.2139509916306
28s 228ms TrieStruct<String, Int> 52662 28.2283940315247
16s 8ms TrieStruct<String, Int> 52662 16.0084500312805
15s 868ms TrieStruct<String, Int> 52662 15.8676519989967
========================= ========================= =========================
========================= 2016-02-17 11:30:00 +0000 =========================

========================= 2016-02-17 11:16:40 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
TPTP_ROOT /Users/Shared/TPTP

LCL129-1 5 literals read in 867µs 963ns from /Users/Shared/TPTP/Problems/LCL/LCL129-1.p
1ms 733µs TailTrie<SymHop, Int> 5 0.00173300504684448
1ms 331µs TailTrie<String, Int> 5 0.00133103132247925
1ms 16µs TrieStruct<SymHop, Int> 5 0.00101596117019653
1ms 387µs TrieStruct<String, Int> 5 0.00138700008392334

SYN000-2 28 literals read in 1ms 284µs from /Users/Shared/TPTP/Problems/SYN/SYN000-2.p
921µs 11ns TailTrie<SymHop, Int> 28 0.000921010971069336
949µs 979ns TailTrie<String, Int> 28 0.000949978828430176
698µs 984ns TrieStruct<SymHop, Int> 28 0.000698983669281006
735µs 998ns TrieStruct<String, Int> 28 0.000735998153686523

PUZ051-1 84 literals read in 4ms 27µs from /Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p
34ms 669µs TailTrie<SymHop, Int> 84 0.0346689820289612
41ms 6µs TailTrie<String, Int> 84 0.0410060286521912
38ms 762µs TrieStruct<SymHop, Int> 84 0.0387620329856873
37ms 442µs TrieStruct<String, Int> 84 0.0374420285224915

HWV074-1 6017 literals read in 367ms 340µs from /Users/Shared/TPTP/Problems/HWV/HWV074-1.p
46s 388ms TailTrie<SymHop, Int> 6017 46.3879140019417
47s 447ms TailTrie<String, Int> 6017 47.4466829895973
29s 566ms TrieStruct<SymHop, Int> 6017 29.5655919909477
30s 565ms TrieStruct<String, Int> 6017 30.5648579597473

HWV105-1 52662 literals read in 657ms 324µs from /Users/Shared/TPTP/Problems/HWV/HWV105-1.p
1m 4s TailTrie<SymHop, Int> 52662 63.807433962822
57s 36ms TailTrie<String, Int> 52662 57.0359500050545
31s 717ms TrieStruct<SymHop, Int> 52662 31.7174170017242
29s 668ms TrieStruct<String, Int> 52662 29.6677749752998
========================= ========================= =========================
========================= 2016-02-17 11:22:19 +0000 =========================
Program ended with exit code: 0

========================= 2016-02-17 10:59:27 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
TPTP_ROOT /Users/Shared/TPTP

LCL129-1 5 literals read in 4ms 51µs from /Users/Shared/TPTP/Problems/LCL/LCL129-1.p
1ms 553µs TailTrie<SymHop, Int> 5 0.0015529990196228
1ms 58µs TrieStruct<SymHop, Int> 5 0.00105798244476318
303µs 30ns TrieStruct<String, Int> 5 0.000303030014038086

SYN000-2 28 literals read in 2ms 363µs from /Users/Shared/TPTP/Problems/SYN/SYN000-2.p
790µs 0ns TailTrie<SymHop, Int> 28 0.000789999961853027
937µs 998ns TrieStruct<SymHop, Int> 28 0.000937998294830322
418µs 7ns TrieStruct<String, Int> 28 0.000418007373809814

PUZ051-1 84 literals read in 3ms 826µs from /Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p
34ms 507µs TailTrie<SymHop, Int> 84 0.0345070362091064
31ms 564µs TrieStruct<SymHop, Int> 84 0.0315639972686768
8ms 275µs TrieStruct<String, Int> 84 0.00827497243881226

HWV074-1 6017 literals read in 407ms 3µs from /Users/Shared/TPTP/Problems/HWV/HWV074-1.p
50s 777ms TailTrie<SymHop, Int> 6017 50.776987016201
30s 709ms TrieStruct<SymHop, Int> 6017 30.7091730237007
1s 711ms TrieStruct<String, Int> 6017 1.71072000265121

HWV105-1 52662 literals read in 592ms 720µs from /Users/Shared/TPTP/Problems/HWV/HWV105-1.p
56s 0ms TailTrie<SymHop, Int> 52662 56.0002590417862
29s 347ms TrieStruct<SymHop, Int> 52662 29.3466069698334
16s 82ms TrieStruct<String, Int> 52662 16.0820810198784
========================= ========================= =========================
========================= 2016-02-17 11:02:34 +0000 =========================
Program ended with exit code: 0

========================= 2016-02-17 07:51:20 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
TPTP_ROOT /Users/Shared/TPTP

LCL129-1
1ms 726µs TailTrie<SymHop, Int> 5 0.00172603130340576
1ms 55µs TrieStruct<SymHop, Int> 5 0.00105500221252441
298µs 977ns TrieStruct<String, Int> 5 0.000298976898193359

SYN000-2
837µs 28ns TailTrie<SymHop, Int> 28 0.000837028026580811
697µs 17ns TrieStruct<SymHop, Int> 28 0.000697016716003418
428µs 21ns TrieStruct<String, Int> 28 0.00042802095413208

PUZ051-1
44ms 539µs TailTrie<SymHop, Int> 84 0.0445389747619629
32ms 819µs TrieStruct<SymHop, Int> 84 0.0328189730644226
16ms 568µs TrieStruct<String, Int> 84 0.0165680050849915

HWV074-1
46s 395ms TailTrie<SymHop, Int> 6017 46.3949609994888
31s 620ms TrieStruct<SymHop, Int> 6017 31.6202830076218
1s 930ms TrieStruct<String, Int> 6017 1.93041801452637

HWV105-1
1m 5s TailTrie<SymHop, Int> 52662 65.1866880059242
29s 182ms TrieStruct<SymHop, Int> 52662 29.182313978672
16s 374ms TrieStruct<String, Int> 52662 16.3743050098419
========================= ========================= =========================
========================= 2016-02-17 07:54:33 +0000 =========================

NyTerms with yices 2.4.1 (x86_64-apple-darwin14.4.0,release,2015-08-10):
/Users/alm/Library/Developer/Xcode/DerivedData/NyTerms-hgbchfqcmrlaxdfodjuqnpiqzqch/Build/Products/Debug/NyTermsCL

LCL129-1
294.0 µs TrieStruct<SymHop, Int> 5 0.00147300958633423
209.0 µs TailTrie<SymHop, Int> 5 0.00104701519012451

SYN000-2
27.0 µs TrieStruct<SymHop, Int> 28 0.000758051872253418
28.0 µs TailTrie<SymHop, Int> 28 0.000789999961853027

PUZ051-1
363.0 µs TrieStruct<SymHop, Int> 84 0.030534029006958
442.0 µs TailTrie<SymHop, Int> 84 0.0371840000152588

HWV074-1
4666.0 µs TrieStruct<SymHop, Int> 6017 28.0810109972954
7944.0 µs TailTrie<SymHop, Int> 6017 47.8007249832153

HWV105-1
561.0 µs TrieStruct<SymHop, Int> 52662 29.5602170228958
1092.0 µs TailTrie<SymHop, Int> 52662 57.5259200334549
Program ended with exit code: 0

*/

/*
NyTerms with yices 2.4.1 (x86_64-apple-darwin14.4.0,release,2015-08-10):
/Users/alm/Library/Developer/Xcode/DerivedData/NyTerms-hgbchfqcmrlaxdfodjuqnpiqzqch/Build/Products/Debug/NyTermsCL

LCL129-1
343.0 µs TailTrie<SymHop, Int> 5 0.00171500444412231
192.0 µs TrieStruct<SymHop, Int> 5 0.000962018966674805

SYN000-2
30.0 µs TailTrie<SymHop, Int> 28 0.000853002071380615
25.0 µs TrieStruct<SymHop, Int> 28 0.00072401762008667

PUZ051-1
394.0 µs TailTrie<SymHop, Int> 84 0.0331739783287048
452.0 µs TrieStruct<SymHop, Int> 84 0.0379839539527893

HWV074-1
7767.0 µs TailTrie<SymHop, Int> 6017 46.7383270263672
4709.0 µs TrieStruct<SymHop, Int> 6017 28.3362950086594

HWV105-1
1066.0 µs TailTrie<SymHop, Int> 52662 56.1873790025711
541.0 µs TrieStruct<SymHop, Int> 52662 28.5403519868851
Program ended with exit code: 0
*/

/*  (without optimized insert for TrieStruct)
NyTerms with yices 2.4.1 (x86_64-apple-darwin14.4.0,release,2015-08-10):
/Users/alm/Library/Developer/Xcode/DerivedData/NyTerms-hgbchfqcmrlaxdfodjuqnpiqzqch/Build/Products/Debug/NyTermsCL

LCL129-1
348.0 µs TailTrie<SymHop, Int> 5 0.00174099206924438
201.0 µs TrieStruct<SymHop, Int> 5 0.00100797414779663

SYN000-2
30.0 µs TailTrie<SymHop, Int> 28 0.000849008560180664
24.0 µs TrieStruct<SymHop, Int> 28 0.000696003437042236

PUZ051-1
392.0 µs TailTrie<SymHop, Int> 84 0.0329380035400391
455.0 µs TrieStruct<SymHop, Int> 84 0.0382260084152222

HWV074-1
7737.0 µs TailTrie<SymHop, Int> 6017 46.5540820360184
4898.0 µs TrieStruct<SymHop, Int> 6017 29.4736059904099

HWV105-1
1110.0 µs TailTrie<SymHop, Int> 52662 58.5058799982071
554.0 µs TrieStruct<SymHop, Int> 52662 29.1821620464325
Program ended with exit code: 0
*/