//
//  Auxiliary+Process.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Process {
    
    private static func argumentValueOf(key:String) -> String? {
        guard let valueIndex = Process.arguments.indexOf(key)?.successor()
            where valueIndex < Process.arguments.count
            else { return nil }
        
        return Process.arguments[valueIndex]
    }
    
    private static func environmentValueOf(key:String) -> String? {
        #if os(OSX)
            return NSProcessInfo.processInfo().environment[key]
        #else
            assert(false)
            return nil
        #endif
    }
    
    static func valueOf(key:String) -> String? {
        if key.hasPrefix("-") {
            return Process.argumentValueOf(key)
        }
        else if (key.uppercaseString == key) {
            return Process.environmentValueOf(key)
        }
        else {
            assert(false,"invalid key format `\(key) for arguments or environment.")
            return nil
        }
    }
    
    #if os(OSX)
    private static var infoOSX : String {
        
        let info = NSProcessInfo.processInfo()
        let host = NSHost.currentHost()
        
        let names = host.names.filter {
            !( $0.hasSuffix("uibk.ac.at") || $0 == "localhost" )
        }
        
        return "\(info.processName) @ " +
            "\(names.first! ?? info.hostName): " +
            "\(info.processorCount) cores, " +
        "\(info.physicalMemory.prettyByteDescription)."
    }
    #endif
    
    static var info : String {
        #if os(OSX)
            return Process.infoOSX
        #else
            return "process info n/a"
        #endif
    }
    
    
    
    
    
    
}
