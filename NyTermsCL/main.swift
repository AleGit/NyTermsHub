//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

print("NyTerms with \(Yices.info):")
print(Process.arguments.joinWithSeparator("\n"))

let hwv134 = "/Users/Shared/TPTP/Problems/HWV/HWV134-1.p"
let puz001 = "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p"
let hwv105 = "/Users/Shared/TPTP/Problems/HWV/HWV105-1.p"
let hwv074 = "/Users/Shared/TPTP/Problems/HWV/HWV074-1.p"

let hwv119 = "/Users/Shared/TPTP/Problems/HWV/HWV119-1.p"

guard Process.arguments.count > 1 else {
    // Samples.parse4Samples()
    
    // Samples.parseHWV105m1(100)
    
    process(hwv134, search:trieSearch)
    exit(0)
}

if Process.arguments.count > 1 {
    
    let path = Process.arguments[1]
    
    let start = NSDate()
    let result = parse(path:path)
    let duration = NSDate().timeIntervalSinceDate(start)
    

    print("\(result.formulae.count) formualae parsed in \(duration) s.")
    
}






