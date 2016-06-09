//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

extension Nylog.LogLevel {
    init(literal:String) {
        switch literal.uppercaseString {
            
        case "0", "OFF":
            self = .OFF
        case "1", "FATAL":
            self = .FATAL
        case "2", "ERROR":
            self = .ERROR
        case "3", "WARN":
            self = .WARN
        case "4", "INFO":
            self = .INFO
        case "5", "DEBUG":
            self = .DEBUG
        case "6", "TRACE":
            self = .TRACE
        case "7", "ALL":
            self = .ALL
        default:
            self = .ERROR
        }
    }
}

struct Nylog {
    enum LogLevel : Int {
        case OFF = 0
        case FATAL = 1
        case ERROR = 2
        case WARN = 3
        case INFO = 4
        case DEBUG = 5
        case TRACE = 6
        case ALL = 7
    }
    
    private static var index = 0
    
    private static var zero = CFAbsoluteTimeGetCurrent()
    private static var lastprint = zero
    private static var logentries = [(LogLevel, String, CFTimeInterval?, CFAbsoluteTime)]()
    
    private static var logprintinterval : CFTimeInterval = 0.0
    private static var logloglevel:LogLevel = .INFO
    
    private static func printconditional() {
        guard logprintinterval > 0 && (CFAbsoluteTimeGetCurrent() - lastprint) > logprintinterval
            else { return }
        
        
        printparts()
        lastprint = CFAbsoluteTimeGetCurrent()
        
    }
    
    static func reset(printinterval:CFTimeInterval = 0.0, loglevel:LogLevel = .INFO) {
        logentries.removeAll()
        index = 0
        zero = CFAbsoluteTimeGetCurrent()
        
        lastprint = zero
        logprintinterval = printinterval
        logloglevel = loglevel
        
        let count = Process.arguments.count
        log("\(Process.arguments[0])")
        log("\(Process.arguments[1..<count])")
    }
    
    
    private static func printit(range:Range<Int>) {
        for (level,key,duration,moment) in logentries[range] {
            let prefix : String = "*\(level)>>> \(key) •••"
            let suffix : String = "at \(moment.prettyTimeIntervalDescription)"
            
            if let runtime = duration {
                print(prefix,"runtime = \(runtime.prettyTimeIntervalDescription)",suffix)
            } else {
                print(prefix,suffix)
            }
        }
    }
    
    private static func printit() {
        printit(0..<logentries.count)
    }
    
    static func printparts() {
        let range = index..<logentries.count
        index = range.endIndex
        printit(range)
        
    }
    
    private static func logappend(@autoclosure msg:()->String, loglevel:LogLevel, @autoclosure duration:()->CFTimeInterval?) {
        assert(loglevel != .OFF)
        assert(loglevel != .ALL)
        
        // check if the log level of the application is higher than the log level of the message
        if logloglevel.rawValue >= loglevel.rawValue {
            logentries.append((loglevel, msg(), duration() , CFAbsoluteTimeGetCurrent()-zero))
            printconditional()
        }
    }
    
    static func measure<R>(@autoclosure msg:()->String, loglevel:LogLevel = .INFO, f:()->R) -> (R,CFTimeInterval) {
        let start = CFAbsoluteTimeGetCurrent()
        let result = f()
        let end = CFAbsoluteTimeGetCurrent()
        
        logappend(msg, loglevel:loglevel,duration:end-start)
        
        
        return (result,end-start)
    }
    
    private static func log(@autoclosure msg:()->String, loglevel:LogLevel = .INFO) {
        logappend(msg, loglevel:loglevel, duration:nil)
    }
    
    
    
    static func fatal(@autoclosure msg:()->String) {
        log(msg, loglevel:.FATAL)
    }
    
    static func error(@autoclosure msg:()->String) {
        log(msg, loglevel:.ERROR)
    }
    
    static func warn(@autoclosure msg:()->String) {
        log(msg, loglevel:.WARN)
    }
    
    static func info(@autoclosure msg:()->String) {
        log(msg, loglevel:.INFO)
    }
    
    static func debug(@autoclosure msg:()->String) {
        log(msg, loglevel:.DEBUG)
    }
    
    static func trace(@autoclosure msg:()->String) {
        log(msg, loglevel:.TRACE)
    }
}

func measure<R>(f:()->R) -> (R, CFAbsoluteTime){
    let start = CFAbsoluteTimeGetCurrent()
    let result = f()
    let end = CFAbsoluteTimeGetCurrent()
    
    return (result, end-start)
}

func doitif(@autoclosure condition: ()->Bool, action:()->Void) {
    if condition() {
        action()
    }
}

func errorNumberAndDescription() -> (Int32,String) {
    let errorNumber = errno
    let cstring = strerror(errorNumber) // will always return a valid c string.
    guard let errorString = String.fromCString(cstring) else {
        let message = "Invalid Error Number: \(errorNumber) (this should be impossible)"
        return (errorNumber,message)
    }
    return (errorNumber,errorString)
}

// MARK: -

extension Array where Element : Hashable {
    var hashValue: Int {
        return self.reduce(5381) {
            ($0 << 5) &+ $0 &+ $1.hashValue
        }
    }
}


extension Array {
    
    
    func permuter<T:Hashable>() -> (
        (before:[T]) -> ( (after:[T]) -> [Element])
        )
    {
        return {
            (before) in return {
                (after) in return
                self.permute(before,after:after)
            }
            
        }
        
    }
    
    func permute<T:Hashable>(before:[T], after:[T]) -> [Element] {
        assert(Set(before) == Set(after))
        assert(before.count == after.count)
        assert(self.count == before.count)
        
        let beforeIndices = before.elementPlaces
        let afterIndices = after.elementPlaces
        
        var target = self
        
        for (key,sourceIndices) in beforeIndices {
            guard let targetIndices = afterIndices[key] else {
                assert(false)
                break
            }
            // assert(sourceIndices.count == targetIndices.count)
            if sourceIndices.count != targetIndices.count {
                //                print(before, after)
                //                print(beforeIndices, afterIndices)
                //                print(sourceIndices, targetIndices)
            }
            
            for (sourceIndex, targetIndex) in zip(sourceIndices, targetIndices) {
                target[targetIndex] = self[sourceIndex]
            }
        }
        
        return target
    }
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

extension SequenceType where Generator.Element : Comparable {
    typealias E = Generator.Element
    func minMaxElementPair() -> (E,E)? {
        return self.reduce(nil) {
            (pair:(E,E)?, element:E) -> (E,E)? in
            guard let (inmin, inmax) = pair else {
                return (element,element) // first element of sequence is minimum and maximum so far
            }
            return (min(inmin,element), max(inmax,element))
        }
    }
}

extension Range where Element: Comparable {
    /// create range such that all elements in the sequence are in the range
    init?<S:SequenceType where S.Generator.Element == Element>(sequence: S) {
        guard let (minimum,maximum) = sequence.minMaxElementPair()
            else { return nil } // empty sequence has neihter minimum nor maximum.
        assert (minimum <= maximum)
        self = minimum...maximum
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
    //    func contains(string:StringSymbol) -> Bool {
    //        return self.rangeOfString(string) != nil
    //    }
    func containsOne<S:SequenceType where S.Generator.Element == StringSymbol>(strings:S) -> Bool {
        return strings.reduce(false) { $0 || self.containsString($1) }
    }
    func containsAll<S:SequenceType where S.Generator.Element == StringSymbol>(strings:S) -> Bool {
        return strings.reduce(true) { $0 && self.containsString($1) }
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



extension SequenceType where Generator.Element : Hashable {
    typealias Element = Generator.Element
    
    var elementPlaces : [Element : [Int]] {
        var eo = [Element : [Int]]()
        for (index,value) in self.enumerate() {
            var array = eo[value] ?? [Int]()
            array.append(index)
            eo[value] = array
        }
        return eo
    }
    
    var elementCounts : [Element: Int] {
        var ec = [Element : Int]()
        for value in self {
            var count = ec[value] ?? 0
            count += 1
            ec[value] = count
        }
        
        return ec
    }
}

/// cartesic product of two sequences
func *<L,R,LS:SequenceType,RS:SequenceType where LS.Generator.Element==L, RS.Generator.Element == R>(lhs:LS,rhs:RS) -> [(L,R)] {
    var a  = [(L,R)]()
    for l in lhs {
        for r in rhs {
            a.append((l,r))
            
        }
    }
    return a
}

// MARK: -


extension Set {
    mutating func uniqueify(inout member: Element) {
        guard let index = self.indexOf(member) else {
            self.insert(member)
            return
        }
        
        member = self[index]
    }
}

//extension Double {
//    init<I:IntegerType>(_ v:I) {
//        assert(false, "\(#function) \(v)")
//        self = 0.0
//    }
//}
//
//extension IntegerType {
//    init(_ v:Double) {
//        assert(false, "\(#function) \(v)")
//        self = 0
//    }
//}
//
//func percent<I:IntegerType>(dividend:I, divisor:I) -> I {
//    let result = 0.5 + 100.0 * (Double(dividend) / Double(divisor))
//    return I(result)
//}

func percent(dividend:Int, divisor:Int) -> Int {
    let result = 0.5 + 100.0 * (Double(dividend) / Double(divisor))
    return Int(result)
}

extension Int {
    /// decode first component
    var first: Int {
        return self >> 32
    }
    
    /// decode second component
    var second: Int {
        return (self << 32) >> 32
    }
    
    /// encode two ints into one (this can overflow)
    init(first:Int,second:Int) {
        
        assert(Int(Int32.min) <= first && first <= Int(Int32.max), "Clause index \(first) is not in range \((Int32.min,Int32.max))")
        assert(Int(Int32.min) <= second && second <= Int(Int32.max), "Literal index \(second) is not in range \((Int32.min,Int32.max))")
        
        self = (first << 32) ^ (second & 0x0000_0000_FFFF_FFFF)
    }
}

// MARK: - mingy helpers



func eqfunc(symbols:[String : SymbolQuadruple]) -> (hasEquations:Bool, functors:[(String, SymbolQuadruple)]) {
    let hasEquations = symbols.reduce(false) { (a:Bool,b:(String,SymbolQuadruple)) in a || b.1.category == .Equational }
    let functors = symbols.filter { (a:String,q:SymbolQuadruple) in q.category == .Functor }
    return (hasEquations,functors)
}

func maxarity(functors:[(String , SymbolQuadruple)]) -> Int {
    return functors.reduce(0) { max($0,$1.1.arity.max) }
}

func axioms(symbols:[String : SymbolQuadruple]) -> [TptpNode]? {
    Nylog.trace("\(#function) \(#line) \(#file)")
    
    let (hasEquations, functors) = eqfunc(globalStringSymbols)
    
    Nylog.info(hasEquations ? "Problem is equational" : "problem is not equational")
    
    guard hasEquations else {
        return nil
    }
    
    var axioms = [TptpNode]()
    
    let reflexivity = TptpNode(connective:"|",nodes: ["X=X"])
    let symmetry = "X!=Y|Y=X" as TptpNode
    let transitivity = "X!=Y | Y!=Z | X=Z" as TptpNode
    
    axioms.append(reflexivity)
    axioms.append(symmetry)
    axioms.append(transitivity)
    
    let maxArity = maxarity(functors)
    
    if maxArity > 3 {
        Nylog.warn("The maximum arity \(maxarity) of symbols is too big.")
    }
    
    
    let tptpVariables = (1...maxArity).map {
        (TptpNode(variable:"X\($0)"), TptpNode(variable:"Y\($0)"))
    }
    
    for (symbol,quadruple) in functors {
        Nylog.debug("\(symbol) \(quadruple)")
        var arity = -1
        switch quadruple.arity {
        case .None:
            assert(false)
            break
        case .Fixed(let v):
            arity = v
            break
        case .Variadic(_):
            assert(false)
            break
        }
        
        assert(arity < maxArity)
        
        guard arity > 0 else {
            // c == c
            // ~p | p
            continue
        }
        
        var literals = [TptpNode]()
        var xargs = [TptpNode]()
        var yargs = [TptpNode]()
        
        literals.reserveCapacity(arity)
        
        for i in 0..<arity {
            let (X,Y) = tptpVariables[i]
            let literal = TptpNode(equational:"!=", nodes:[X,Y])
            literals.append(literal)
            xargs.append(X)
            yargs.append(Y)
        }
        switch quadruple.type {
        case .Predicate:
            let npx = TptpNode(connective:"~", nodes:[TptpNode(predicate:symbol, nodes:xargs)])
            let py = TptpNode(predicate:symbol, nodes:yargs)
            literals.append(npx)
            literals.append(py)
        case .Function:
            let fx = TptpNode(function:symbol, nodes:xargs)
            let fy = TptpNode(function:symbol, nodes:yargs)
            let fx_eq_fy = TptpNode(equational:"=", nodes:[fx,fy])
            literals.append(fx_eq_fy)
        default:
            assert(false)
            break
        }
        
        let congruence = TptpNode(connective:"|", nodes:literals)
        axioms.append(congruence)
        
    }
    
    return axioms
}


