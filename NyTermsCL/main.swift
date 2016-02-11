//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

print("NyTerms with \(Yices.info):")
print(Process.arguments.joinWithSeparator("\n"))

buildTriesDemo()

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




