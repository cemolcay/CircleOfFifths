//
//  CircleOfFifths.swift
//  CircleOfFifths
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

import AppKit
import MusicTheorySwift

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
}

internal enum CircleChordType {
  case major
  case minor
  case diminished
}

public typealias UIView = NSView
public typealias UIColor = NSColor
public typealias UIFont = NSFont
public typealias UIBezierPath = NSBezierPath

@IBDesignable
public class CircleOfFifths: UIView {
  public var scale = Scale(type: .minor, key: .c) { didSet { draw() }}
  @IBInspectable public var defaultColor: UIColor = .white { didSet { draw() }}
  @IBInspectable public var highlightedColor: UIColor = .red { didSet { draw() }}
  @IBInspectable public var disabledColor: UIColor = .lightGray { didSet { draw() }}
  @IBInspectable public var fontSize: CGFloat = 15 { didSet { draw() }}
  @IBInspectable public var textColor: UIColor = .black { didSet { draw() }}
  @IBInspectable public var textTreshold: CGFloat = 10  { didSet { draw() }}
  @IBInspectable public var chordPieHeight: CGFloat = 10 { didSet { draw() }}
  @IBInspectable public var chordPieLineColor: UIColor = .black { didSet { draw() }}
  @IBInspectable public var chordPieLineWidth: CGFloat = 1 { didSet { draw() }}
  @IBInspectable public var circlePieLineColor: UIColor = .black { didSet { draw() }}
  @IBInspectable public var circlePieLineWidth: CGFloat = 1 { didSet { draw() }}
  @IBInspectable public var majorColor: UIColor = .red { didSet { draw() }}
  @IBInspectable public var minorColor: UIColor = .blue { didSet { draw() }}
  @IBInspectable public var diminishedColor: UIColor = .green { didSet { draw() }}

  private var circle: [NoteType] = [.c, .g, .d, .a, .e, .b, .gFlat, .dFlat, .aFlat, .eFlat, .bFlat, .f]
  private var chords: [CircleChordType] = [.major, .major, .major, .minor, .minor, .minor, .diminished]

  private var chordPie: PieChartLayer?
  private var circlePie: PieChartLayer?

  public override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    if chordPie == nil || circlePie == nil {
      setup()
    }

    draw()
  }

  private func setup() {
    let center = CGPoint(x: bounds.midX, y: bounds.midY)

    let chordColor: (CircleChordType) -> UIColor = { type in
      switch type {
      case .major: return self.majorColor
      case .minor: return self.minorColor
      case .diminished: return self.diminishedColor
      }
    }

    chordPie = PieChartLayer(
      radius: 0,
      center: center,
      slices: chords.map({
        PieChartSlice(
          startAngle: 0,
          endAngle: 0,
          color: chordColor($0))
      }))

    circlePie = PieChartLayer(
      radius: 0,
      center: center,
      slices: circle.map({
        PieChartSlice(
          startAngle: $0.circleStartAngle,
          endAngle: $0.circleEndAngle,
          color: defaultColor,
          highlightedColor: highlightedColor,
          disabledColor: disabledColor,
          attributedString: NSAttributedString(
            string: "\($0)",
            attributes: [
              NSForegroundColorAttributeName: textColor,
              NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize)
            ]))
      }))

    guard let chordPie = chordPie,
      let circlePie = circlePie
      else { return }

    wantsLayer = true
    layer?.addSublayer(chordPie)
    layer?.addSublayer(circlePie)
  }

  private func draw() {
    guard let chordPie = chordPie,
      let circlePie = circlePie
      else { return }

    chordPie.strokeColor = chordPieLineColor.cgColor
    chordPie.lineWidth = chordPieLineWidth
    circlePie.strokeColor = circlePieLineColor.cgColor
    circlePie.lineWidth = circlePieLineWidth

    let radius = max(0, min(frame.size.width, frame.size.height) / 2)
    chordPie.radius = radius
    circlePie.radius = max(0, radius - chordPieHeight)

    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    chordPie.center = center
    circlePie.center = center
    circlePie.labelPositionTreshold = textTreshold
    
    let rootNote = scale.key + scale.type.circleModeRootInterval
    var chordNotes = [NoteType]()
    for i in 0..<chords.count {
      if i == 0 {
        chordNotes.append(rootNote)
      } else {
        guard let previousNote = chordNotes.last else { break }
        chordNotes.append(previousNote + .P5)
      }
    }

    for (index, note) in circle.enumerated() {
      let noteSlice = circlePie.slices[index]
      if let noteIndex = chordNotes.index(of: note) {
        let chordSlice = chordPie.slices[noteIndex]
        chordSlice.startAngle = note.circleStartAngle
        chordSlice.endAngle = note.circleEndAngle
        noteSlice.isEnabled = true
      } else {
        noteSlice.isEnabled = false
      }
    }
  }
}
