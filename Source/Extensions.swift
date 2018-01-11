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
#elseif os(iOS) || os(tvOS)
  public typealias CRView = UIView
  public typealias CRColor = UIColor
  public typealias CRFont = UIFont
  public typealias CRBezierPath = UIBezierPath
#endif

// MARK: - CGFloat Extension

internal extension CGFloat {
  var radians: CGFloat {
    return self * .pi / 180.0
  }
}

extension CGSize {
    static let max = CGSize(width: .max, height: .max)
}

// MARK: - NSBezierPath Extension

#if os(OSX)
  public extension NSBezierPath {
    public var cgPath: CGPath {
      let path = CGMutablePath()
      var points = [CGPoint](repeating: .zero, count: 3)

      for i in 0 ..< self.elementCount {
        let type = self.element(at: i, associatedPoints: &points)
        switch type {
        case .moveToBezierPathElement:
          path.move(to: points[0])
        case .lineToBezierPathElement:
          path.addLine(to: points[0])
        case .curveToBezierPathElement:
          path.addCurve(to: points[2], control1: points[0], control2: points[1])
        case .closePathBezierPathElement:
          path.closeSubpath()
        }
      }

      return path
    }
  }
#endif

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
    case .lydian: return .unison
    default: return .unison
    }
  }
}

// MARK: - NoteType Extension

internal extension NoteType {
  internal var circleIndex: Int {
    switch self {
    case .c: return 0
    case .g: return 1
    case .d: return 2
    case .a: return 3
    case .e: return 4
    case .b: return 5
    case .gFlat: return 6
    case .dFlat: return 7
    case .aFlat: return 8
    case .eFlat: return 9
    case .bFlat: return 10
    case .f: return 11
    }
  }

  #if os(OSX)
    internal var circleStartAngle: CGFloat {
    switch self {
    case .c: return -15
    case .f: return 15
    case .bFlat: return 45
    case .eFlat: return 75
    case .aFlat: return 105
    case .dFlat: return 135
    case .gFlat: return 165
    case .b: return 195
    case .e: return 225
    case .a: return 255
    case .d: return 285
    case .g: return 315
    }
  }

  internal var circleEndAngle: CGFloat {
    switch self {
    case .c: return 15
    case .f: return 45
    case .bFlat: return 75
    case .eFlat: return 105
    case .aFlat: return 135
    case .dFlat: return 165
    case .gFlat: return 195
    case .b: return 225
    case .e: return 255
    case .a: return 285
    case .d: return 315
    case .g: return 345
    }
  }
  #elseif os(iOS) || os(tvOS)
  internal var circleStartAngle: CGFloat {
    switch self {
    case .c: return -15
    case .g: return 15
    case .d: return 45
    case .a: return 75
    case .e: return 105
    case .b: return 135
    case .gFlat: return 165
    case .dFlat: return 195
    case .aFlat: return 225
    case .eFlat: return 255
    case .bFlat: return 285
    case .f: return 315
    }
  }

  internal var circleEndAngle: CGFloat {
    switch self {
    case .c: return 15
    case .g: return 45
    case .d: return 75
    case .a: return 105
    case .e: return 135
    case .b: return 165
    case .gFlat: return 195
    case .dFlat: return 225
    case .aFlat: return 255
    case .eFlat: return 285
    case .bFlat: return 315
    case .f: return 345
    }
  }
  #endif
}
