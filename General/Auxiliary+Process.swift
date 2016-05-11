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
            "\(platform), " +
            "\(info.processorCount) cores, " +
            "\(info.physicalMemory.prettyByteDescription), " +
            "\(self.cpuFrequency.prettyHzDescription)" +
        " (mark:\(benchmark))"
    }
    #endif
    
    static var info : String {
        #if os(OSX)
            return Process.infoOSX
        #else
            return "process info n/a"
        #endif
    }
    
    static var platform : String {
        #if os(OSX)
        var size : size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        
        var machine = [CChar](count: Int(size), repeatedValue: 0)
        
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        
        return String.fromCString(machine) ?? "n/a"
        #else
        return "n/a"
        #endif
    }

    
    static var cpuFrequency : UInt64 {
        return sysctl("hw.cpufrequency")
    }
    
    /// higher is better
    static var benchmark : Double = {
        let size = 1_000_000
        let (_,runtime) = measure {
            let v1 = CFAbsoluteTimeGetCurrent()
            
            
            let sum = (1...size).map { _ in v1 }.reduce(0.0) { $0+$1 }
            
            let v2 = sum / Double(size)
            assert(v1 / 1.01 < v2)
            assert(v1 * 1.01 > v2)
        }
        return Double(size) / runtime / 2_345_678.901
        
        // goal:iMac24-7 (none) ~ 0.3
        // iMac24-7 (optimized) is about
        //
        // MacMini12 is about
        // MacMini14 is about
    }()
    

    
    private static func sysctl<T where T:Defaultable>(name:String) -> T {
        var size : size_t = 0
        var t : T = T()
        
        var code = sysctlbyname(name, nil, &size, nil, 0);
        
        assert(code == 0 && size > 0,"\(#function)(\(name) did not work. code:\(code), size:\(size)")

        code = sysctlbyname(name, &t, &size, nil, 0);
        
        assert(code == 0 && size > 0,"\(#function)(\(name) did not work. code:\(code), size:\(size)")
        
        return t
        
    }
    
    
}

protocol Defaultable {
    init()
}

extension String : Defaultable { }

extension UInt64 : Defaultable { }

extension Double : Defaultable { }


