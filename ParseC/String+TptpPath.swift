//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// Absolute path to a tptp file, i.e. a problem or an axiom.
///
///     /Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p
///     /Users/Shared/TPTP/Axioms/PUZ001-0.ax
typealias TptpPath = String

/// A tptp path to a file contains three components.
///
/// - 'root' is the TPTP directory with problems and axioms,
/// - 'local' is a local path from root and starts with 'Axioms' or 'Problems',
/// - 'last' is the file name with extension of the axiom or problem.
///
/// (root:/Users/Shared/TPTP/,local:Problems/PUZ/,last:PUZ001-1.p)
///
/// (root:/Users/Shared/TPTP/,local:Axioms/,last:PUZ001-0.ax)
typealias TptpPathComponents = (root:TptpPath,local:TptpPath,last:TptpPath)

extension TptpPath {
    /// Splits a tptp path to its components.
    ///
    /// "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p" -> (root:"/Users/Shared/TPTP/",local:"Problems/PUZ/",last:"PUZ001-1.p")
    private func tptpPathComponents () -> TptpPathComponents {
        var rootPath = [TptpPath]()
        var localPath = [TptpPath]()
        
        var isRootPathComponent = true
        for pathComponent in ((self as NSString).stringByDeletingLastPathComponent as NSString).pathComponents {
            switch pathComponent {
            case "Axioms", "Problems":
                isRootPathComponent = false;
            default:
                break;
            }
            
            if isRootPathComponent {
                rootPath.append(pathComponent)
            } else {
                localPath.append(pathComponent)
            }
        }
        
        return (NSString.pathWithComponents(rootPath), NSString.pathWithComponents(localPath), (self as NSString).lastPathComponent)
    }
    
    /// TPTP problem files can include axioms, i.e. the local path to an axiom file.
    /// It is assumed that `file` share the same root path as `self`.
    func tptpPathTo(file:TptpPath) -> TptpPath {
        let (root,_,_) = self.tptpPathComponents()
        let (_,local,last) = file.tptpPathComponents()
        
        guard !local.isEmpty else { return (root as NSString).stringByAppendingPathComponent(last) }
        
        return ((root as NSString).stringByAppendingPathComponent(local) as NSString).stringByAppendingPathComponent(last)
    }
    
    /// Find path to tptp include file (usually an axiom).
    func tptpPathTo(include: TptpInclude) -> TptpPath {
        return self.tptpPathTo(include.fileName)
    }
    
    private static func tptpRootPathFromProcessArguments () -> TptpPath? {
        var tptp = false
        for argument in Process.arguments {
            if tptp {
                return argument // last argument was -tptp
            }
            if argument == "-tptp" {
                tptp = true // return next argument
            }
        }
        
        return nil
    }
    
    static let tptpRootPath : TptpPath = {
        if let argument = TptpPath.tptpRootPathFromProcessArguments() {
            print("-tptp \(argument)")
            return argument
        }
        
        let environment = NSProcessInfo.processInfo().environment
        if let argument = environment["TPTP_ROOT"] {
            print("TPTP_ROOT=\"\(argument)\"")
            return argument
        }
        
        let message = "neither -tptp nor TPTP_ROOT were set"
        assert(false,message)
        let defaultTptpRootPath = "/Users/Shared/TPTP"
        print(message, defaultTptpRootPath)
        return defaultTptpRootPath
    }()
    
    /// construct absolute path from file name (without local path or extension)
    /// by process (envionment) argument and convention.
    var p:String {
        assert(self.rangeOfString("/") == nil,"\(self)")    // assert file name only
        assert(!self.hasSuffix(".p"),"\(self)")    // assert without extension p
        assert(!self.hasSuffix(".ax"),"\(self)")    // assert without extension ax
        //        let components = (self as NSString).pathComponents
        //        assert(components.size < 3)
        
        let ABC = self[self.startIndex..<self.startIndex.advancedBy(3)]
        assert(ABC.uppercaseString == ABC,"\(ABC)")
        
        let path = NSString.pathWithComponents([
            TptpPath.tptpRootPath, // e.g. /Users/Shared/TPTP
            "Problems", // by convention problem files are in the local directory
            ABC, // 'Problems/ABC' where ABC matches the first three letters of the file name
            self]) // self is the file name without extension, e.g. XYZ001-1
        let full = (path as NSString).stringByAppendingPathExtension("p")!
        return full // e.g. /Users/Shared/TPTP/Problems/XYZ/XYZ001-1.p
    }
}
