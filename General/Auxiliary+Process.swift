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
            else {
                assert(false, "unbalanced number of arguments \(Process.arguments.count)")
                return nil
        }
        
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
        "\(info.physicalMemory.prettyByteDescription), " +
        "\(self.speed.prettyHzDescription)."
    }
    #endif
    
    static var info : String {
        #if os(OSX)
            return Process.infoOSX
        #else
            return "process info n/a"
        #endif
    }
    
    static var speed : UInt64 {
        var size : size_t = 8
        var value : UInt64 = 0

        // let result = sysctlbyname("hw.cpufrequency_max", nil, &size, nil, 0);
        var code = sysctlbyname("hw.cpufrequency", nil, &size, nil, 0);
        
        assert(code == 0, "\(code) \(value) \(size)")
        assert(size == 8, "\(code) \(value) \(size)")
        
        code = sysctlbyname("hw.cpufrequency", &value, &size, nil, 0);
        assert(code == 0, "\(code) \(value) \(size)")
        assert(size == sizeof(UInt64), "\(code) \(value) \(size)")
        
        return value
    }
    
    static var relativeSpeed : Double {
        return Double(self.speed) / 3_000_000_000.0
        
        
        
    }
    
    
    
    
    
    
    
    
}
