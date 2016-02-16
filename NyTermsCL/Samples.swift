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
    
    private static func parse1Sample(file:TptpPath, limit:(CFTimeInterval,CFTimeInterval)) {
        let start = CFAbsoluteTimeGetCurrent()
        let (_,tptpFormulae,_) = parse(path:file)
        let total = CFAbsoluteTimeGetCurrent() - start
        let average = total / Double(tptpFormulae.count)
        let name = (file as NSString).lastPathComponent
        
        let message = "'\(name)' total:\(Double(Int(total*1000))/1000.0)s, limit:\(limit)s, count:\(tptpFormulae.count) avg:\(Double(Int(average*1000_000))/1000.0)ms"
        print("// *** \(message) *** ")

    }
    
    static func parseHWV105m1(count:Int) {
       let path = "HWV105-1".p
        
        for i in 1...count {
            print(i, terminator:":\t")
            parse1Sample(path, limit:(0.0,0.5))
        }
    }
    
    static func parse4Samples() {
        for (path,limit) in [
            ("HWV105-1".p,( 1.5,  0.5)),
            ("HWV062+1".p,( 0.5,  0.7)),
            ("HWV134+1".p,(11.0, 17.2)),
            
            ("HWV134-1".p,(40.0, 78.0)),
            
            ("HWV134+1".p,(11.0, 51.6)),
            ("HWV062+1".p,( 0.5, 22.2)),
            ("HWV105-1".p,( 1.5,  0.5))
            ] {
                
                parse1Sample(path, limit:limit)
                
        }
    }
}
