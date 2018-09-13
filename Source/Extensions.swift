//
//  Extensions.swift
//  CircleOfFifths
//
//  Created by Cem Olcay on 15/04/2017.
//
//

#if os(OSX)
  import AppKit
#elseif os(iOS) || os(tvOS)
  import UIKit
#endif
import MusicTheorySwift

// MARK: - Typealiases

#if os(OSX)
  public typealias CRView = NSView
  public typealias CRColor = NSColor
  public typealias CRFont = NSFont
  public typealias CRBezierPath = NSBezierPath

  public extension NSBezierPath {
    public var cgPath: CGPath {
      let path = CGMutablePath()
      var points = [CGPoint](repeating: .zero, count: 3)

      for i in 0 ..< self.elementCount {
        let type = self.element(at: i, associatedPoints: &points)
        switch type {
        case .moveTo:
          path.move(to: points[0])
        case .lineTo:
          path.addLine(to: points[0])
        case .curveTo:
          path.addCurve(to: points[2], control1: points[0], control2: points[1])
        case .closePath:
          path.closeSubpath()
        }
      }

      return path
    }
  }
#elseif os(iOS) || os(tvOS)
  public typealias CRView = UIView
  public typealias CRColor = UIColor
  public typealias CRFont = UIFont
  public typealias CRBezierPath = UIBezierPath
#endif

extension NSAttributedString {
  var boundingRect : CGRect {
    #if os(OSX)
      if #available(OSX 10.11, *) {
        return boundingRect(with: .max,
                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                            context: nil)

      } else {
        return string.boundingRect(with: .max,
                                   options: [.usesLineFragmentOrigin, .usesFontLeading],
                                   attributes: attributes(at: 0, effectiveRange: nil))

      }
    #elseif os(iOS) || os(tvOS)
      return boundingRect(with: .max,
                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                          context: nil)
    #endif
  }
}

// MARK: - CGFloat Extension

internal extension CGFloat {
  var radians: CGFloat {
    return self * .pi / 180.0
  }
}

extension CGSize {
  static let max = CGSize(width: .max, height: .max)
}


// MARK: - ScaleType Extension

internal extension ScaleType {
  internal var circleModeRootInterval: Interval {
    switch self {
    case .major: return .P4
    case .minor: return .m6
    case .dorian: return .m3
    case .locrian: return .d5
    case .mixolydian: return .m7
    case .phrygian: return .m2
    case .lydian: return .P1
    default: return .P1
    }
  }
}

// MARK: - NoteType Extension

internal extension Key {
  internal var circleIndex: Int {
    switch self {
    case "c": return 0
    case "g": return 1
    case "d": return 2
    case "a": return 3
    case "e": return 4
    case "b": return 5
    case "gb", "f#": return 6
    case "db", "c#": return 7
    case "ab", "g#": return 8
    case "eb", "d#": return 9
    case "bb", "a#": return 10
    case "f": return 11
    default: return 0
    }
  }

  #if os(OSX)
    internal var circleStartAngle: CGFloat {
    switch self {
    case "c": return -15
    case "g": return 15
    case "d": return 45
    case "a": return 75
    case "e": return 105
    case "b": return 135
    case "gb", "f#": return 165
    case "db", "c#": return 195
    case "ab", "g#": return 225
    case "eb", "d#": return 255
    case "bb", "a#": return 285
    case "f": return 315
    default: return 0
    }
  }

  internal var circleEndAngle: CGFloat {
    switch self {
    case "c": return 15
    case "f": return 45
    case "bb", "a#": return 75
    case "eb", "d#": return 105
    case "ab", "g#": return 135
    case "db", "c#": return 165
    case "gb", "f#": return 195
    case "b": return 225
    case "e": return 255
    case "a": return 285
    case "d": return 315
    case "g": return 345
    default: return 0
    }
  }
  #elseif os(iOS) || os(tvOS)
  internal var circleStartAngle: CGFloat {
    switch self {
    case "c": return -15
    case "g": return 15
    case "d": return 45
    case "a": return 75
    case "e": return 105
    case "b": return 135
    case "gb", "f#": return 165
    case "db", "c#": return 195
    case "ab", "g#": return 225
    case "eb", "d#": return 255
    case "bb", "a#": return 285
    case "f": return 315
    default: return 0
    }
  }

  internal var circleEndAngle: CGFloat {
    switch self {
    case "c": return 15
    case "g": return 45
    case "d": return 75
    case "a": return 105
    case "e": return 135
    case "b": return 165
    case "gb", "f#": return 195
    case "db", "c#": return 225
    case "ab", "g#": return 255
    case "eb", "d#": return 285
    case "bb", "a#": return 315
    case "f": return 345
    default: return 0
    }
  }
  #endif
}
