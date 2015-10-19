//  Created by alm on 30/08/15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

// (Sunday, 30 August 2015 at 10:51:47 Central European Summer Time '/Users/Shared/TPTP/Problems/HWV/HWV062+1.p'
// *** 'HWV062+1.p' total:0.631s, limit:0.7s, count:2 avg:315.721ms ***
// *** 'HWV062+1.p' total:0.755s, limit:2.0s, count:2 avg:377.844ms ***
// (Sunday, 30 August 2015 at 10:51:48 Central European Summer Time '/Users/Shared/TPTP/Problems/HWV/HWV134-1.p'
// *** 'HWV134-1.p' total:49.438s, limit:49.5s, count:2332428 avg:0.021ms ***
// *** 'HWV134-1.p' total:64.744s, limit:150.0s, count:2332428 avg:0.027ms ***
// (Sunday, 30 August 2015 at 10:52:37 Central European Summer Time '/Users/Shared/TPTP/Problems/HWV/HWV105-1.p'
// *** 'HWV105-1.p' total:1.262s, limit:1.3s, count:20900 avg:0.06ms ***
// *** 'HWV105-1.p' total:1.01s, limit:1.5s, count:20900 avg:0.048ms *** 
// (Sunday, 30 August 2015 at 10:52:38 Central European Summer Time '/Users/Shared/TPTP/Problems/HWV/HWV134+1.p'
// *** 'HWV134+1.p' total:14.732s, limit:14.8s, count:128975 avg:0.114ms ***
// *** 'HWV134+1.p' total:39.361s, limit:90.0s, count:128975 avg:0.305ms ***

struct Samples {
    static var tptpPath = "/Users/Shared/TPTP/Problems/"
    
    private static func parse1Sample(file:TptpPath, limit:NSTimeInterval) {

        
        let start = NSDate()
        let (_,tptpFormulae,_) = parsePath(file)
        let end = NSDate()
        
        let total = end.timeIntervalSinceDate(start)
        
        let average = total / Double(tptpFormulae.count)
        
        
        let name = (file as NSString).lastPathComponent
        print("// (\(NSDate()) '\(name)'\(Symbols.info)")
        
        let message = "'\(name)' total:\(Double(Int(total*1000))/1000.0)s, limit:\(limit)s, count:\(tptpFormulae.count) avg:\(Double(Int(average*1000_000))/1000.0)ms"
        print("// *** \(message) *** ")
        
        
        
        // assert(total < limit*4, message)

    }
    
    static func parse4Samples() {
        for (localPath,limit) in [
            "Problems/HWV/HWV134-1.p" : 50.0,
            "Problems/HWV/HWV105-1.p" : 2.5,
            "Problems/HWV/HWV134+1.p" : 15,
            "Problems/HWV/HWV062+1.p" : 1.5
            ] {
                
                let filePath = tptpPath.tptpPathTo(localPath)
                parse1Sample(filePath, limit:limit)
                
        }
    }
}
