//  Created by Alexander Maringele.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

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
        
        assert(localPath.count > 0)
        assert(localPath.first == "Problems" || localPath.first == "Axioms")
        
        return (NSString.pathWithComponents(rootPath), NSString.pathWithComponents(localPath), (self as NSString).lastPathComponent)
    }
    
    /// TPTP problem files can include axioms, i.e. a path to an axiom file.
    /// 1. `file` is absolute path (untested)
    /// 2. `file` shares path prefix with `self` (default)
    /// 3. `file` is relative tptp root path. (untested)
    func tptpPathTo(file:TptpPath) -> TptpPath? {
        
        // 1, `file` is absolute path
        
        if file.isAccessibleFile {
            assert(false,"\(self).tptpPathTo(file:\(file)): use case with absolute file path is untested.")
            return file // allready a tptpPath, i.e. a absolute path to a file
        }
        
        let (root,_,_) = self.tptpPathComponents()
        
        assert(root == TptpPath.tptpRootPath,"\(self).tptpPathTo(file:\(file)): use case with paths outside of root path is untested.")
        
        let (empty,axiom,last) = file.tptpPathComponents()
        
        assert(axiom.hasPrefix("Axioms"),"\(self).tptpPathTo(file:\(file)): use case with local file path component different form 'Axioms' is untested.")
        assert(empty.isEmpty,"\(self).tptpPathTo(file:\(file)): use case with non-empty file path component before 'Axioms' is untested.")
        
        // 2. `file` shares path prefix with `self`
        
        let path = axiom.isEmpty ? (root as NSString).stringByAppendingPathComponent(last)
            : ((root as NSString).stringByAppendingPathComponent(axiom) as NSString).stringByAppendingPathComponent(last)
        
        print(self,"tptpPathTo(file:",file,") ->",path)
        
        if path.isAccessibleFile { return path }
        
        assert(false,"untested use case: \(self) does not share root path with \(file)")
        
        // 3. `file` is relative to tptp root path.
        
        let rootPath = axiom.isEmpty ? (TptpPath.tptpRootPath as NSString).stringByAppendingPathComponent(last)
            : ((TptpPath.tptpRootPath as NSString).stringByAppendingPathComponent(axiom) as NSString).stringByAppendingPathComponent(last)
        
        if rootPath.isAccessibleFile { return rootPath }
        
        // `file` is not accessible
        
        assert(false,"\(self).tptpPathTo(file:\(file)): Neither '\(path)' nor '\(rootPath)' are accessible.")
        
        return nil
    }
    
    /// Find path to tptp include file (usually an axiom).
    func tptpPathTo(include: TptpInclude) -> TptpPath? {
        return self.tptpPathTo(include.fileName)
    }
    
    private static func accessibleDirectory(path:TptpPath?, label : String = "no label") -> TptpPath? {
        guard let path = path else {
            let message = "\(label) was set, but root path is missing or empty."
            print(message)
            return nil
        }
        
        guard path.isAccessibleDirectory else {
            let message = "Directory '\(path)' is not an accessible. (\(label))"
            print(message)
            return nil
        }
        
        return path
    }
    
    /// Tries to get accessible root path to tptp files from process arguments.
    private static var tptpRootPathArgument : TptpPath? {
        let name = "-tptp_root"
        
        var tptp = false
        for argument in Process.arguments {
            if tptp {
                return accessibleDirectory(argument, label:name)    // last argument was -tptp_root
            }
            if argument == name {
                tptp = true                             // return next argument
            }
        }
        
        return nil
    }
    
    /// Tries to get accessible root path to tptp files from environment variable.
    private static var tptpRootPathEnvironement : TptpPath? {
        let name = "TPTP_ROOT"
        let result = NSProcessInfo.processInfo().environment[name]
        return accessibleDirectory(result, label: name)
    }
    
    private static let tptpRootPathDefault = "/Users/Shared/TPTP"
    
    /// Gets root path to tptp files from process arguments or environment.
    /// Returns `tptpRootPathDefault` if congigured path is not accessible,
    /// e.g. does not exists or current process has not permissions.
    static let tptpRootPath : TptpPath = {
        guard let result = TptpPath.tptpRootPathArgument ?? TptpPath.tptpRootPathEnvironement else {
            let message = "Neither argument -tptp_root nor environment variable TPTP_ROOT were set correctly."
            print(message)
            assert(tptpRootPathDefault.isAccessibleDirectory,"neither configured nor or default tptp root path are accessible.")
            return tptpRootPathDefault
        }
        
        return result
    }()
    
    /// construct absolute path from problem file name (without local path or extension)
    /// with tptp root path and the convention of three uppercase letter directory names.
    var p:TptpPath? {
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
        
        guard full.isAccessibleFile else {
            let (errorNumber,errorString) = errorNumberAndDescription()
            print(errorNumber,errorString)
            return nil
        }
        
        return full // e.g. /Users/Shared/TPTP/Problems/XYZ/XYZ001-1.p
    }
    
    private var isAccessibleDirectory : Bool {
        let d = opendir(self)
        guard d != nil else {
            return false
        }
        closedir(d)
        return true
    }
    
    private var isAccessibleFile : Bool {
        let f = fopen(self,"r")
        guard f != nil else {
            return false
        }
        fclose(f)
        return true
    }
}