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
        
        // assert(localPath.count > 0)
        // assert(localPath.first == "Problems" || localPath.first == "Axioms")
        
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
        
        
        let (empty,axiom,last) = file.tptpPathComponents()
        
        assert(empty.isEmpty,"\(self).tptpPathTo(file:\(file)): use case with non-empty file path component before 'Axioms' is untested.")
        
        // 2. `file` shares path prefix with `self`
        
        let path = axiom.isEmpty ? (root as NSString).stringByAppendingPathComponent(last)
            : ((root as NSString).stringByAppendingPathComponent(axiom) as NSString).stringByAppendingPathComponent(last)
        
        Nylog.info("\(self) \(#function)(\(file) -> \(path)")
        
        if path.isAccessibleFile { return path }
        
        // 3. `file` is relative to tptp root path.
        
        let rootPath = axiom.isEmpty ? (TptpPath.tptpRootPath as NSString).stringByAppendingPathComponent(last)
            : ((TptpPath.tptpRootPath as NSString).stringByAppendingPathComponent(axiom) as NSString).stringByAppendingPathComponent(last)
        
        if rootPath.isAccessibleFile { return rootPath }
        
        // `file` is not accessible
        
        return nil
    }
    
    /// Find path to tptp include file (usually an axiom).
    func tptpPathTo(include: TptpInclude) -> TptpPath? {
        return self.tptpPathTo(include.fileName)
    }
    
    private static func accessibleDirectory(path:TptpPath?, label : String = "no label") -> TptpPath? {
        guard let path = path else {
            Nylog.warn("Key '\(label)' is not set or its value was missing.")
            return nil
        }
        
        guard path.isAccessibleDirectory else {
            Nylog.warn("Key '\(label)' was set but directory '\(path)' is not an accessible.")
            return nil
        }
        
        return path
    }
    
    /// Tries to get accessible root path to tptp files from process arguments.
    private static var tptpRootPathArgument : TptpPath? {
        let argumentKey = "-tptp_root"
        return accessibleDirectory(Process.valueOf(argumentKey), label: argumentKey)
    }
    
    /// Tries to get accessible root path to tptp files from environment variable.
    private static var tptpRootPathEnvironement : TptpPath? {
        let environmentKey = "TPTP_ROOT"
        return accessibleDirectory(Process.valueOf(environmentKey), label: environmentKey)
    }
    
    private static let tptpRootPathDefault = "/Users/Shared/TPTP"
    
    /// Gets root path to tptp files from process arguments or environment.
    /// Returns `tptpRootPathDefault` if congigured path is not accessible,
    /// e.g. does not exists or current process has not permissions.
    static let tptpRootPath : TptpPath = {
        guard let result = TptpPath.tptpRootPathArgument ?? TptpPath.tptpRootPathEnvironement else {
            Nylog.info("Neither argument -tptp_root nor environment variable TPTP_ROOT were set correctly.")
            assert(tptpRootPathDefault.isAccessibleDirectory,"neither a configured nor the default tptp root path are accessible.")
            return tptpRootPathDefault
        }
        
        return result
    }()

    /// Check if `self` is an accessible file. If not treat `self` as problem name 
    /// (without local path or extension) and construct absolute path from it
    /// with tptp root path and the convention of three uppercase letter directory names.
    var p:TptpPath? {
        if self.isAccessibleFile { return self }
        
        // check if problem name is just a name without path or extension
        
        assert(self.rangeOfString("/") == nil,"\(self)")    // assert file name only
        assert(!self.hasSuffix(".p"),"\(self)")    // assert without extension p
        assert(!self.hasSuffix(".ax"),"\(self)")    // assert without extension ax
        
        // extract first thre uppercase letters of problem name
        
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
            Nylog.warn("\(self) \(errorNumber) \(errorString) \(full)")
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
    
     var isAccessibleFile : Bool {
        let f = fopen(self,"r")
        guard f != nil else {
            return false
        }
        fclose(f)
        return true
    }
    
    /// total size of file in bytes
    var fileSize : Int? {
        var status = stat()
        let code = stat(self, &status)
        switch (code, S_IFREG & status.st_mode) {
        case (0,S_IFREG):
            return Int(status.st_size)
        default:
            Nylog.warn("\(code) \(status.st_mode)")
            return nil
        }
        
    }
}