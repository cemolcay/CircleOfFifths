//
//  CircleOfFifths.swift
//  CircleOfFifths
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

#if os(OSX)
  import AppKit
#elseif os(iOS)
  import UIKit
#endif
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
  #elseif os(iOS)
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

internal enum CircleChordType {
  case major
  case minor
  case diminished
}

#if os(OSX)
  public typealias CRView = NSView
  public typealias CRColor = NSColor
  public typealias CRFont = NSFont
  public typealias CRBezierPath = NSBezierPath
#elseif os(iOS)
  public typealias CRView = UIView
  public typealias CRColor = UIColor
  public typealias CRFont = UIFont
  public typealias CRBezierPath = UIBezierPath
#endif

@IBDesignable
public class CircleOfFifths: CRView {
  public var scale = Scale(type: .minor, key: .c) { didSet { draw() }}
  @IBInspectable public var defaultColor: CRColor = .white { didSet { draw() }}
  @IBInspectable public var highlightedColor: CRColor = .red { didSet { draw() }}
  @IBInspectable public var disabledColor: CRColor = .lightGray { didSet { draw() }}
  @IBInspectable public var fontSize: CGFloat = 15 { didSet { draw() }}
  @IBInspectable public var textColor: CRColor = .black { didSet { draw() }}
  @IBInspectable public var textTreshold: CGFloat = 10  { didSet { draw() }}
  @IBInspectable public var chordPieHeight: CGFloat = 10 { didSet { draw() }}
  @IBInspectable public var chordPieLineColor: CRColor = .black { didSet { draw() }}
  @IBInspectable public var chordPieLineWidth: CGFloat = 1 { didSet { draw() }}
  @IBInspectable public var circlePieLineColor: CRColor = .black { didSet { draw() }}
  @IBInspectable public var circlePieLineWidth: CGFloat = 1 { didSet { draw() }}
  @IBInspectable public var majorColor: CRColor = .red { didSet { draw() }}
  @IBInspectable public var minorColor: CRColor = .blue { didSet { draw() }}
  @IBInspectable public var diminishedColor: CRColor = .green { didSet { draw() }}
  @IBInspectable public var majorTextColor: CRColor = .black { didSet { draw() }}
  @IBInspectable public var minorTextColor: CRColor = .black { didSet { draw() }}
  @IBInspectable public var diminishedTextColor: CRColor = .black { didSet { draw() }}
  @IBInspectable public var majorFontSize: CGFloat = 15 { didSet { draw() }}
  @IBInspectable public var minorFontSize: CGFloat = 15 { didSet { draw() }}
  @IBInspectable public var diminishedFontSize: CGFloat = 15 { didSet { draw() }}
  @IBInspectable public var majorTextTreshold: CGFloat = 5 { didSet { draw() }}
  @IBInspectable public var minorTextTreshold: CGFloat = 5 { didSet { draw() }}
  @IBInspectable public var diminishedTextTreshold: CGFloat = 5 { didSet { draw() }}
  @IBInspectable public var intervalPieHeight: CGFloat = 10 { didSet { draw() }}
  @IBInspectable public var intervalFontSize: CGFloat = 15 { didSet { draw() }}
  @IBInspectable public var intervalTextTreshold: CGFloat = 15 { didSet { draw() }}

  private var circle: [NoteType] = [.c, .g, .d, .a, .e, .b, .gFlat, .dFlat, .aFlat, .eFlat, .bFlat, .f]
  private var chords: [CircleChordType] = [.major, .major, .major, .minor, .minor, .minor, .diminished]

  private var chordPie: PieChartLayer?
  private var circlePie: PieChartLayer?
  private var intervalPie: PieChartLayer?
  private var selectedSlice: PieChartSlice?
  private var majorArcText: ArcTextLayer?
  private var minorArcText: ArcTextLayer?
  private var dimArcText: ArcTextLayer?

  #if os(OSX)
    public override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    draw()
  }
  #elseif os(iOS)
    public override func draw(_ rect: CGRect) {
      super.draw(rect)
      draw()
    }
  #endif

  public func selectNote(note: NoteType?) {
    selectedSlice?.isSelected = false
    guard let note = note,
      let slice = circlePie?.slices[note.circleIndex]
      else { return }
    slice.isSelected = true
    selectedSlice = slice
    circlePie?.layoutSublayers()
  }

  private func setup() {
    let center = CGPoint(x: bounds.midX, y: bounds.midY)

    let chordColor: (CircleChordType) -> CRColor = { type in
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
              NSFontAttributeName: CRFont.boldSystemFont(ofSize: fontSize)
            ]))
      }))


    intervalPie = PieChartLayer(
      radius: 0,
      center: center,
      slices: chords.map({ _ in
        PieChartSlice(
          startAngle: 0,
          endAngle: 0,
          color: defaultColor)
      }))

    majorArcText = ArcTextLayer()
    minorArcText = ArcTextLayer()
    dimArcText = ArcTextLayer()

    guard let chordPie = chordPie,
      let circlePie = circlePie,
      let intervalPie = intervalPie,
      let majorArcText = majorArcText,
      let minorArcText = minorArcText,
      let dimArcText = dimArcText
      else { return }

    #if os(OSX)
      wantsLayer = true
      guard let layer = layer else { return }
    #endif

    layer.addSublayer(chordPie)
    layer.addSublayer(circlePie)
    layer.addSublayer(intervalPie)
    layer.addSublayer(majorArcText)
    layer.addSublayer(minorArcText)
    layer.addSublayer(dimArcText)
  }

  private func draw() {
    if chordPie == nil || circlePie == nil {
      setup()
    }

    guard let chordPie = chordPie,
      let circlePie = circlePie,
      let intervalPie = intervalPie
      else { return }

    // Set layer colors
    chordPie.strokeColor = chordPieLineColor.cgColor
    chordPie.lineWidth = chordPieLineWidth
    circlePie.strokeColor = circlePieLineColor.cgColor
    circlePie.lineWidth = circlePieLineWidth
    intervalPie.strokeColor = circlePieLineColor.cgColor
    intervalPie.lineWidth = circlePieLineWidth

    // Set size
    let radius = max(0, min(frame.size.width, frame.size.height) / 2)
    chordPie.radius = radius
    circlePie.radius = max(0, radius - chordPieHeight)
    intervalPie.radius = max(0, intervalPieHeight)

    // Set position
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    chordPie.center = center
    circlePie.center = center
    circlePie.labelPositionTreshold = textTreshold
    intervalPie.center = center
    intervalPie.labelPositionTreshold = intervalTextTreshold

    // Determine chord notes
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

    // Draw chord pie
    for (index, note) in circle.enumerated() {
      let noteSlice = circlePie.slices[index]
      if let noteIndex = chordNotes.index(of: note) {
        let chordSlice = chordPie.slices[noteIndex]
        chordSlice.startAngle = note.circleStartAngle
        chordSlice.endAngle = note.circleEndAngle

        let intervalSlice = intervalPie.slices[noteIndex]
        intervalSlice.startAngle = note.circleStartAngle
        intervalSlice.endAngle = note.circleEndAngle
        intervalSlice.attributedString = NSAttributedString(
          string: toRomanInterval(note: note, chordMode: chords[noteIndex]),
          attributes: [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: CRFont.systemFont(ofSize: intervalFontSize)
          ])

        noteSlice.isEnabled = true
      } else {
        noteSlice.isEnabled = false
      }
    }

    // Draw chord type over chord pie
    #if os(OSX)
      let majorAngle = chordNotes[1].circleStartAngle + 15 + 90
      let minorAngle = chordNotes[4].circleStartAngle + 15 + 90
      let dimAngle = chordNotes[6].circleStartAngle + 15 + 90
    #elseif os(iOS)
      let majorAngle = chordNotes[1].circleStartAngle + 15 - 90
      let minorAngle = chordNotes[4].circleStartAngle + 15 - 90
      let dimAngle = chordNotes[6].circleStartAngle + 15 - 90
    #endif

    majorArcText?.text = NSAttributedString(
      string: "Major",
      attributes: [
        NSForegroundColorAttributeName: majorTextColor,
        NSFontAttributeName: CRFont.systemFont(ofSize: majorFontSize)
      ])
    majorArcText?.angle = majorAngle
    majorArcText?.radius = radius - majorTextTreshold
    majorArcText?.frame = bounds

    minorArcText?.text = NSAttributedString(
      string: "Minor",
      attributes: [
        NSForegroundColorAttributeName: minorTextColor,
        NSFontAttributeName: CRFont.systemFont(ofSize: minorFontSize)
      ])
    minorArcText?.angle = minorAngle
    minorArcText?.radius = radius - minorTextTreshold
    minorArcText?.frame = bounds

    dimArcText?.text = NSAttributedString(
      string: "Dim",
      attributes: [
        NSForegroundColorAttributeName: diminishedTextColor,
        NSFontAttributeName: CRFont.systemFont(ofSize: diminishedFontSize)
      ])
    dimArcText?.angle = dimAngle
    dimArcText?.radius = radius - diminishedTextTreshold
    dimArcText?.frame = bounds

    chordPie.setNeedsDisplay()
    circlePie.setNeedsDisplay()
    intervalPie.setNeedsDisplay()
    majorArcText?.setNeedsDisplay()
    minorArcText?.setNeedsDisplay()
    dimArcText?.setNeedsDisplay()
  }

  private func toRomanInterval(note: NoteType, chordMode: CircleChordType) -> String {
    let notes = scale.noteTypes
    let index = Int(notes.index(of: note) ?? 10)
    var roman = ""
    switch index {
    case 0: roman = "i"
    case 1: roman = "ii"
    case 2: roman = "iii"
    case 3: roman = "iv"
    case 4: roman = "v"
    case 5: roman = "vi"
    case 6: roman = "vii"
    case 7: roman = "viii"
    default: roman = ""
    }

    switch chordMode {
    case .major: return roman.uppercased()
    case .diminished: return "\(roman)°"
    default: return roman
    }
  }
}