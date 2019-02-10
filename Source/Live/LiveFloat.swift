//
//  LiveFloat.swift
//  Pixels
//
//  Created by Hexagons on 2018-11-23.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics

extension CGFloat {
    init(_ liveFloat: LiveFloat) {
        self = liveFloat.value
    }
}
extension Float {
    init(_ liveFloat: LiveFloat) {
        self = Float(liveFloat.value)
    }
}
extension Double {
    init(_ liveFloat: LiveFloat) {
        self = Double(liveFloat.value)
    }
}
//extension Int {
//    init(_ liveFloat: LiveFloat) {
//        self = Int(liveFloat.value)
//    }
//}

public class MetalUniform {
    public var name: String
    public var value: LiveFloat
    public init(name: String, value: LiveFloat = 0.0) {
        self.name = name
        self.value = value
    }
}

public class LiveFloat: LiveValue, /*Equatable, Comparable,*/ ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible/*, BinaryFloatingPoint */ {
    
    var name: String?
    
    public var description: String {
        let _value: CGFloat = round(CGFloat(self) * 1_000) / 1_000
        return "live(\("\(_value)".zfill(3)))"
    }
    
    var futureValue: () -> (CGFloat)
    var value: CGFloat {
        return futureValue()
    }
    public var cg: CGFloat {
        return value
    }
    
    var uniform: CGFloat {
        get {
            uniformCache = CGFloat(self)
            return CGFloat(self)
        }
    }
    var uniformIsNew: Bool {
        return uniformCache != CGFloat(self)
    }
    var uniformCache: CGFloat? = nil
    
    public static var pi: LiveFloat { return LiveFloat(CGFloat.pi) }
    
    //    public var year: LiveFloat!
    //    public var month: LiveFloat!
    //    public var day: LiveFloat!
    //    public var hour: LiveFloat!
    //    public var minute: LiveFloat!
    //    public var second: LiveFloat!
    public static var seconds: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return Pixels.main.seconds
        })
    }
    public static var secondsSince1970: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return CGFloat(Date().timeIntervalSince1970)
        })
    }
    
    var isFrozen: Bool = false
    public static var live: LiveFloat {
        var value: CGFloat = 0.0
        var lastFrame: Int = -1
        return LiveFloat({ () -> (CGFloat) in
            guard lastFrame != Pixels.main.frame else {
                lastFrame = Pixels.main.frame
                return value
            }
            if !self.live.isFrozen {
                value += 1.0 / CGFloat(Pixels.main.fps)
            }
            lastFrame = Pixels.main.frame
            return value
        })
    }
    
    
    public init(_ futureValue: @escaping () -> (CGFloat)) {
        self.futureValue = futureValue
    }
    
    public init(_ liveInt: LiveInt) {
        futureValue = { return CGFloat(Int(liveInt)) }
    }
    
    public init(_ value: CGFloat) {
        futureValue = { return value }
    }
    public init(_ value: Float) {
        futureValue = { return CGFloat(value) }
    }
    required public init(floatLiteral value: FloatLiteralType) {
        futureValue = { return CGFloat(value) }
    }
    
    public init(_ value: Int) {
        futureValue = { return CGFloat(value) }
    }
    required public init(integerLiteral value: IntegerLiteralType) {
        futureValue = { return CGFloat(value) }
    }
    
    public init(name: String, value: CGFloat) {
        self.name = name
        futureValue = { return value }
    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) == CGFloat(rhs) })
    }
    public static func != (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return !(lhs == rhs)
    }
//    public static func == (lhs: LiveFloat, rhs: CGFloat) -> LiveBool {
//        return lhs.value == rhs
//    }
//    public static func == (lhs: CGFloat, rhs: LiveFloat) -> LiveBool {
//        return lhs == rhs.value
//    }
    
    // MARK: Comparable
    
    public static func < (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) < CGFloat(rhs) })
    }
    public static func <= (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) <= CGFloat(rhs) })
    }
    public static func > (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) > CGFloat(rhs) })
    }
    public static func >= (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) >= CGFloat(rhs) })
    }
//    public static func < (lhs: LiveFloat, rhs: CGFloat) -> LiveBool {
//        return LiveFloat({ return lhs.value < rhs })
//    }
//    public static func < (lhs: CGFloat, rhs: LiveFloat) -> LiveBool {
//        return LiveFloat({ return lhs < rhs.value })
//    }
    
    // MARK: Operators
    
    public static func + (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs) + CGFloat(rhs) })
    }
    public static func += (lhs: inout LiveFloat, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) + CGFloat(rhs) })
    }
    
    public static func - (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs) - CGFloat(rhs) })
    }
    public static func -= (lhs: inout LiveFloat, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) - CGFloat(rhs) })
    }
    
    public static func * (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs) * CGFloat(rhs) })
    }
    public static func *= (lhs: inout LiveFloat, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) * CGFloat(rhs) })
    }
    
    public static func / (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs) / CGFloat(rhs) })
    }
    public static func /= (lhs: inout LiveFloat, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) / CGFloat(rhs) })
    }
    
    
    public static func ** (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return pow(CGFloat(lhs), CGFloat(rhs)) })
    }
    
    public static func !** (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return pow(CGFloat(lhs), 1.0 / CGFloat(rhs)) })
    }
    
    public static func % (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs).truncatingRemainder(dividingBy: CGFloat(rhs)) })
    }
    
    
    public static func <> (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return min(CGFloat(lhs), CGFloat(rhs)) })
    }
    
    public static func >< (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return max(CGFloat(lhs), CGFloat(rhs)) })
    }
    
    
    public prefix static func - (operand: LiveFloat) -> LiveFloat {
        return LiveFloat({ return -CGFloat(operand) })
    }
    
    public prefix static func ! (operand: LiveFloat) -> LiveFloat {
        return LiveFloat({ return 1.0 - CGFloat(operand) })
    }
    
    
    public static func <=> (lhs: LiveFloat, rhs: LiveFloat) -> (LiveFloat, LiveFloat) {
        return (lhs, rhs)
    }
    
    // MARK: Flow Funcs
    
    public func delay(frames: LiveInt) -> LiveFloat {
        var cache: [CGFloat] = []
        return LiveFloat({ () -> (CGFloat) in
            cache.append(CGFloat(self))
            if cache.count > Int(frames) {
                return cache.remove(at: 0)
            }
            return cache.first!
        })
    }
    
    public func delay(seconds: LiveFloat) -> LiveFloat {
        var cache: [(date: Date, value: CGFloat)] = []
        return LiveFloat({ () -> (CGFloat) in
            let delaySeconds = max(Double(seconds), 0)
            guard delaySeconds > 0 else {
                return CGFloat(self)
            }
            cache.append((date: Date(), value: CGFloat(self)))
            for _ in cache {
                if -cache.first!.date.timeIntervalSinceNow > delaySeconds {
                    cache.remove(at: 0)
                    continue
                }
                break
            }
            return cache.first!.value
        })
    }
    
    /// filter over frames. smooth off is linear. smooth on is cosine smoothness (default)
    public func filter(frames: LiveInt, smooth: Bool = true) -> LiveFloat {
        var cache: [CGFloat] = []
        return LiveFloat({ () -> (CGFloat) in
            cache.append(CGFloat(self))
            if cache.count > Int(frames) {
                return cache.remove(at: 0)
            }
            var filteredValue: CGFloat = 0.0
            for value in cache {
                filteredValue += value
            }
            filteredValue /= CGFloat(cache.count)
            return filteredValue
        })
    }
    
    /// filter over seconds. smooth off is linear. smooth on is cosine smoothness (default)
    public func filter(seconds: LiveFloat, smooth: Bool = true) -> LiveFloat {
        var cache: [(date: Date, value: CGFloat)] = []
        return LiveFloat({ () -> (CGFloat) in
            let delaySeconds = max(Double(seconds), 0)
            guard delaySeconds > 0 else {
                return CGFloat(self)
            }
            cache.append((date: Date(), value: CGFloat(self)))
            for _ in cache {
                if -cache.first!.date.timeIntervalSinceNow > delaySeconds {
                    cache.remove(at: 0)
                    continue
                }
                break
            }
            var filteredValue: CGFloat = 0.0
            var weight: CGFloat = smooth ? 0.0 : CGFloat(cache.count)
            for (i, dateValue) in cache.enumerated() {
                let fraction = CGFloat(i) / CGFloat(cache.count - 1)
                let smoothWeight: CGFloat = 1.0 - (cos(fraction * .pi * 2) / 2 + 0.5)
                filteredValue += dateValue.value * (smooth ? smoothWeight : 1.0)
                weight += smoothWeight
            }
            filteredValue /= weight
            return filteredValue
        })
    }
    
    /// noise is a combo of liveRandom and smooth filter
    ///
    /// deafults - liveRandom range: 0.0...1.0 - filter seconds: 1.0
    public static func noise(range: ClosedRange<CGFloat> = 0...1.0, seconds: LiveFloat = 1.0) -> LiveFloat {
        return LiveFloat.liveRandom(in: range).filter(seconds: seconds, smooth: true)
    }
    
    public static func wave(range: ClosedRange<CGFloat> = 0...1.0, seconds: LiveFloat = 1.0) -> LiveFloat {
        return (cos((self.seconds / seconds) * .pi * 2) / -2 + 0.5).lerp(from: LiveFloat(range.lowerBound), to: LiveFloat(range.upperBound))
    }

//    public static func range(from rangeA: ClosedRange<CGFloat> = 0...1.0, to rangeB: ClosedRange<CGFloat> = 0...1.0) -> LiveFloat {
//        return self...
//    }

    func lerp(from: LiveFloat, to: LiveFloat) -> LiveFloat {
        return from * (1.0 - self) + to * self
    }
    
    // MARK: Local Funcs
    
    public func truncatingRemainder(dividingBy other: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(self).truncatingRemainder(dividingBy: CGFloat(other)) })
    }

    public func remainder(dividingBy other: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(self).remainder(dividingBy: CGFloat(other)) })
    }
    
    public static func random(in range: Range<CGFloat>) -> LiveFloat {
        return LiveFloat(CGFloat.random(in: range))
    }
    public static func random(in range: ClosedRange<CGFloat>) -> LiveFloat {
        return LiveFloat(CGFloat.random(in: range))
    }
    
    public static func liveRandom(in range: Range<CGFloat>) -> LiveFloat {
        return LiveFloat({ return CGFloat.random(in: range) })
    }
    public static func liveRandom(in range: ClosedRange<CGFloat>) -> LiveFloat {
        return LiveFloat({ return CGFloat.random(in: range) })
    }
    
}


// MARK: Global Funcs

public func round(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return round(CGFloat(live)) })
}
public func floor(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return floor(CGFloat(live)) })
}
public func ceil(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return ceil(CGFloat(live)) })
}

public func sqrt(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return sqrt(CGFloat(live)) })
}
public func pow(_ live: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return pow(CGFloat(live), CGFloat(live2)) })
}

public func cos(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return cos(CGFloat(live)) })
}
public func sin(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return sin(CGFloat(live)) })
}
public func atan(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return atan(CGFloat(live)) })
}
public func atan2(_ live1: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return atan2(CGFloat(live1), CGFloat(live2)) })
}

public func maximum(_ live1: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return Swift.max(CGFloat(live1), CGFloat(live2)) })
}
public func minimum(_ live1: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return Swift.min(CGFloat(live1), CGFloat(live2)) })
}

// MARK: New Global Funcs

public func deg(rad live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return (CGFloat(live) / .pi / 2.0) * 360.0 })
}
public func rad(deg live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return (CGFloat(live) / 360.0) * .pi * 2.0 })
}

public func freeze(_ live: LiveFloat, _ frozen: LiveBool) -> LiveFloat {
    var frozenLive: CGFloat? = nil
    return LiveFloat({
        live.isFrozen = frozen.value
        if !live.isFrozen {
            frozenLive = live.value
        }
        return live.isFrozen ? frozenLive ?? 0.0 : live.value
    })
}