//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

func measure<R>(f:()->R) -> (R, CFAbsoluteTime){
    let start = CFAbsoluteTimeGetCurrent()
    let result = f()
    let end = CFAbsoluteTimeGetCurrent()
    
    return (result, end-start)
}

// MARK: -

extension Range where Element : Comparable {
    /// expands range if value is not in range
    /// - successor `struct Range<Element : ForwardIndexType>`
    ///
    /// - `func min<T : Comparable>(x: T, _ y: T) -> T`
    ///
    /// - `func max<T : Comparable>(x: T, _ y: T) -> T`
    mutating func insert(value:Element) {
        guard !self.contains(value) else { return }
        
        self.startIndex = min(self.startIndex, value)
        self.endIndex = max(self.endIndex, value.successor())
    }
}

extension Range where Element: Comparable {
    /// create range such that all elements in the sequence are in the range
    init?<S:SequenceType where S.Generator.Element == Element>(sequence: S) {
        guard let
            minimum = sequence.minElement(),
            maximum = sequence.maxElement()
            else { return nil }
        assert (minimum <= maximum)
        
        self.init(start:minimum, end:maximum.successor())
    }
}

// MARK: -

extension Dictionary {
    // get all keys where the values match a predicate
    func keys(predicate : (Element)->Bool) -> [Key] {
        return self.filter { predicate($0) }.map { $0.0 }
    }
}


// MARK: -
extension String  {
    func contains(string:Symbol) -> Bool {
        return self.rangeOfString(string) != nil
    }
    func containsOne<S:SequenceType where S.Generator.Element == Symbol>(strings:S) -> Bool {
        return strings.reduce(false) { $0 || self.contains($1) }
    }
    func containsAll<S:SequenceType where S.Generator.Element == Symbol>(strings:S) -> Bool {
        return strings.reduce(true) { $0 && self.contains($1) }
    }
}

// MARK: -

extension CollectionType
where Generator.Element : CustomStringConvertible {
    func joinWithSeparator(separator:String) -> String {
        return self.map { $0.description }.joinWithSeparator(separator)
    }
}

//extension CollectionType
//where Generator.Element == SubSequence.Generator.Element {
//    var decompose: (head: Generator.Element, tail: SubSequence)? {
//        guard let head = first else { return nil }
//        return (head, dropFirst())
//    }
//}

extension CollectionType
where Generator.Element == SubSequence.Generator.Element {
    var decompose: (head: Generator.Element, tail: [Generator.Element])? {
        guard let head = first else { return nil }
        return (head, Array(dropFirst()))
    }
}


// MARK: -

extension SequenceType {
    
    func all(predicate: Generator.Element -> Bool) -> Bool {
        return self.reduce(true) { $0 && predicate($1) }
    }
    
    func one(predicate: Generator.Element -> Bool) -> Bool {
        return self.reduce(false) { $0 || predicate($1) }
    }
    
    func count(predicate: Generator.Element -> Bool) -> Int {
        return self.reduce(0) { $0 + (predicate($1) ? 1 : 0) }
    }
}

// MARK: -

extension CFTimeInterval {
    static let hour = 3600.0
    static let minute = 60.0
    static let second = 1.0
    static let ms = 0.001
    static let µs = 0.000_001
    static let ns = 0.000_000_001
    static let units = [
        hour : "h",
        minute : "m",
        second : "s",
        ms: "ms",
        µs : "µs",
        ns : "ns"
    ]
    
    var timeIntervalDescriptionMarkedWithUnits : String {
        var t = self
        switch self {
        case _ where floor(t/CFAbsoluteTime.hour) > 0:
            t += 0.5*CFAbsoluteTime.minute // round minute
            let hour = t/CFAbsoluteTime.hour
            t -= floor(hour)*CFAbsoluteTime.hour
            let minute = t/CFAbsoluteTime.minute
            return "\(Int(hour))\(CFAbsoluteTime.units[CFAbsoluteTime.hour]!)" + " \(Int(minute))\(CFAbsoluteTime.units[CFAbsoluteTime.minute]!)"
            
        case _ where floor(t/CFAbsoluteTime.minute) > 0:
            t += 0.5*CFAbsoluteTime.second // round second
            let minute = t/CFAbsoluteTime.minute
            t -= floor(minute)*CFAbsoluteTime.minute
            let second = t/CFAbsoluteTime.second
            return "\(Int(minute))\(CFAbsoluteTime.units[CFAbsoluteTime.minute]!)" + " \(Int(second))\(CFAbsoluteTime.units[CFAbsoluteTime.second]!)"
            
        case _ where floor(t/CFAbsoluteTime.second) > 0:
            t += 0.5*CFAbsoluteTime.ms // round ms
            let second = t/CFAbsoluteTime.second
            t -= floor(second)*CFAbsoluteTime.second
            let ms = t/CFAbsoluteTime.ms
            return "\(Int(second))\(CFAbsoluteTime.units[CFAbsoluteTime.second]!)" + " \(Int(ms))\(CFAbsoluteTime.units[CFAbsoluteTime.ms]!)"
            
        case _ where floor(t/CFAbsoluteTime.ms) > 0:
            t += 0.5*CFAbsoluteTime.µs // round µs
            let ms = t/CFAbsoluteTime.ms
            t -= floor(ms)*CFAbsoluteTime.ms
            let µs = t/CFAbsoluteTime.µs
            return "\(Int(ms))\(CFAbsoluteTime.units[CFAbsoluteTime.ms]!)" + " \(Int(µs))\(CFAbsoluteTime.units[CFAbsoluteTime.µs]!)"
            
        case _ where floor(t/CFAbsoluteTime.µs) > 0:
            t += 0.5*CFAbsoluteTime.ns // round µs
            let µs = t/CFAbsoluteTime.µs
            t -= floor(µs)*CFAbsoluteTime.µs
            let ns = t/CFAbsoluteTime.ns
            return "\(Int(µs))\(CFAbsoluteTime.units[CFAbsoluteTime.µs]!)" + " \(Int(ns))\(CFAbsoluteTime.units[CFAbsoluteTime.ns]!)"
            
        default:
            let ns = t/CFAbsoluteTime.ns
            return "\(ns)\(CFAbsoluteTime.units[CFAbsoluteTime.ns]!)"
            
        }
    }
}

// MARK: -
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
        var result : TptpPath?
        var tptp = false
        for argument in Process.arguments {
            if tptp {
                print("-tptp_root \(argument)")
                result = argument                     // last argument was -tptp
            }
            if argument == "-tptp_root" {
                tptp = true                             // return next argument
            }
            if result != nil {
                break
            }
        }
        assert(!tptp || (result != nil && !result!.isEmpty), "-tptp_root was set, but root path is missing or empty")
        return result
    }
    
    private static func tptpRootPathFromEnvironement () -> TptpPath? {
        let result = NSProcessInfo.processInfo().environment["TPTP_ROOT"]
        assert(result == nil || !result!.isEmpty,"TPTP_ROOT was set, but root path is empty")
        return result
    }
    
    /// Get root path to tptp files from process arguments or environment.
    static let tptpRootPath : TptpPath = {
        if let argument = TptpPath.tptpRootPathFromProcessArguments() ?? TptpPath.tptpRootPathFromEnvironement() {
            return argument
        }
        
        let message = "neither argument -tptp_root nor environment variable TPTP_ROOT were set"
        assert(false,message)
        let defaultTptpRootPath = "/Users/Shared/TPTP"
        print(message, defaultTptpRootPath)
        return defaultTptpRootPath
    }()
    
    /// construct absolute path from file name (without local path or extension)
    /// with tptp root path and convention.
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