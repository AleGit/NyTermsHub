//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    let line = "========================="

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        
        
        // print header
        print(line,NSDate(),line)
        print(Process.info)
        print(Yices.info)
        print("tptp root path:",TptpPath.tptpRootPath)
        print(line,line,line)
        
        

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
        // print footer
        print(line,line,line)
        print(line,NSDate(),line)
    }


}

