//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

let line = "========================="
print(line,NSDate(),line)
print(line,line,line)

print("NyTerms with \(Yices.info)")
print("TPTP_ROOT",TptpPath.tptpRootPath)

BuildTries.demo()
// ParseFiles.demo()

//let key = "hwv066"
//let searches = [intTrieSearch, linearSearch]
//
//var runtime : CFAbsoluteTime = 0
//
//if Process.arguments.count < 2 {
//    for search in searches {
//        
//        (_, runtime) = measure { process(tptpFiles[key]!, search:search) }
//        
//    }
//}
//else if let path = tptpFiles[Process.arguments[1].lowercaseString] {
//    for search in searches {
//        (_, runtime) = measure { process(path, search:search) }
//    }
//}
//else {
//    let path = Process.arguments[1]
//    print(path)
//    (_, runtime) = measure { process(path, search:trieSearch) }
//}
//
//print ("total runtime:",runtime)

print(line,line,line)
print(line,NSDate(),line)


