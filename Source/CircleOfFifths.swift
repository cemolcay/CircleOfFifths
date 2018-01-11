//
//  CircleOfFifths.swift
//  CircleOfFifths
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

#if os(OSX)
  import AppKit
#elseif os(iOS) || os(tvOS)
  import UIKit
#endif
import MusicTheorySwift

internal enum CircleChordType {
  case major
  case minor
  case diminished
}

@IBDesignable
public class CircleOfFifths: CRView {
  public var scale = Scale(type: .minor, key: .c) { didSet { redraw() }}

  @IBInspectable public var defaultColor: CRColor = .white { didSet { redraw() }}
  @IBInspectable public var highlightedColor: CRColor = .red { didSet { redraw() }}
  @IBInspectable public var disabledColor: CRColor = .lightGray { didSet { redraw() }}
  @IBInspectable public var textColor: CRColor = .black { didSet { redraw() }}
  @IBInspectable public var circlePieLineColor: CRColor = .black { didSet { redraw() }}
  @IBInspectable public var majorColor: CRColor = .red { didSet { redraw() }}
  @IBInspectable public var minorColor: CRColor = .blue { didSet { redraw() }}
  @IBInspectable public var diminishedColor: CRColor = .green { didSet { redraw() }}
  @IBInspectable public var majorTextColor: CRColor = .black { didSet { redraw() }}
  @IBInspectable public var minorTextColor: CRColor = .black { didSet { redraw() }}
  @IBInspectable public var diminishedTextColor: CRColor = .black { didSet { redraw() }}
  @IBInspectable public var chordPieLineColor: CRColor = .black { didSet { redraw() }}

  @IBInspectable public var chordPieLineWidth: CGFloat = 1 { didSet { redraw() }}
  @IBInspectable public var circlePieLineWidth: CGFloat = 1 { didSet { redraw() }}
  @IBInspectable public var chordPieHeight: CGFloat = 16 { didSet { redraw() }}
  @IBInspectable public var chordFontSize: CGFloat = 15 { didSet { redraw() }}
  @IBInspectable public var chordTextTreshold: CGFloat = 8 { didSet { redraw() }}

  public var fontSize: CGFloat = 15
  public var textTreshold: CGFloat = 10
  public var intervalPieHeight: CGFloat = 10
  public var intervalFontSize: CGFloat = 15
  public var intervalTextTreshold: CGFloat = 15

  private var circle: [NoteType] = [.c, .g, .d, .a, .e, .b, .gFlat, .dFlat, .aFlat, .eFlat, .bFlat, .f]
  private var chords: [CircleChordType] = [.major, .major, .major, .minor, .minor, .minor, .diminished]

  private var circlePie = PieChartLayer()
  private var intervalPie = PieChartLayer()
  private var chordPie = PieChartLayer()
  private var majorArcText = ArcTextLayer()
  private var minorArcText = ArcTextLayer()
  private var dimArcText = ArcTextLayer()
  private var selectedSlice: PieChartSlice?

  // MARK: Init

  #if os(OSX)
    public override init(frame frameRect: NSRect) {
      super.init(frame: frameRect)
      setup()
    }
  #elseif os(iOS) || os(tvOS)
    public override init(frame: CGRect) {
      super.init(frame: frame)
      setup()
    }
  #endif

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  // MARK: Setup

  private func setup() {
    circlePie.slices = circle.map({
      PieChartSlice(
        startAngle: $0.circleStartAngle,
        endAngle: $0.circleEndAngle,
        attributedString: NSAttributedString(
          string: "\($0)",
          attributes: [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: CRFont.boldSystemFont(ofSize: fontSize)
        ]))
    })

    chordPie.slices = chords.map({ _ in PieChartSlice() })

    intervalPie.slices = chords.map({ _ in
      PieChartSlice(color: defaultColor)
    })

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

  // MARK: Draw

  #if os(OSX)
    public override func layout() {
        super.layout()
        draw()
      }
  #elseif os(iOS) || os(tvOS)
    public override func layoutSubviews() {
      super.layoutSubviews()
      draw()
    }
  #endif

  private func draw() {
    #if os(OSX)
      guard let layer = layer else { return }
    #endif

    let width = min(frame.size.width, frame.size.height)
    fontSize = width * 32.0 / 300.0
    textTreshold = width * 35.0 / 300.0
    intervalPieHeight = width * 60.0 / 300.0
    intervalTextTreshold = width * 18.0 / 300.0
    intervalFontSize = width * 15.0 / 300.0

    // Set layer colors
    chordPie.strokeColor = chordPieLineColor.cgColor
    chordPie.lineWidth = chordPieLineWidth
    circlePie.strokeColor = circlePieLineColor.cgColor
    circlePie.lineWidth = circlePieLineWidth
    intervalPie.strokeColor = circlePieLineColor.cgColor
    intervalPie.lineWidth = circlePieLineWidth

    // Set position
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    chordPie.center = center
    circlePie.center = center
    intervalPie.center = center
    circlePie.labelPositionTreshold = textTreshold
    intervalPie.labelPositionTreshold = intervalTextTreshold

    // Set font
    circlePie.slices.forEach({
      $0.color = defaultColor
      $0.highlightedColor = highlightedColor
      $0.disabledColor = disabledColor
      $0.attributedString = NSAttributedString(
        string: $0.attributedString?.string ?? "",
        attributes: [
          NSForegroundColorAttributeName: textColor,
          NSFontAttributeName: CRFont.boldSystemFont(ofSize: fontSize)
        ])
    })

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
    let chordColor: (CircleChordType) -> CRColor = { type in
      switch type {
      case .major: return self.majorColor
      case .minor: return self.minorColor
      case .diminished: return self.diminishedColor
      }
    }

    for (index, note) in circle.enumerated() {
      let noteSlice = circlePie.slices[index]
      if let noteIndex = chordNotes.index(of: note) {
        let chordSlice = chordPie.slices[noteIndex]
        chordSlice.startAngle = note.circleStartAngle
        chordSlice.endAngle = note.circleEndAngle
        chordSlice.color = chordColor(chords[noteIndex])

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

    // Set size
    let radius = max(0, min(frame.size.width, frame.size.height) / 2)
    chordPie.radius = radius
    circlePie.radius = max(0, radius - chordPieHeight)
    intervalPie.radius = max(0, intervalPieHeight)

    chordPie.frame = layer.bounds
    circlePie.frame = layer.bounds
    intervalPie.frame = layer.bounds

    chordPie.setNeedsLayout()
    circlePie.setNeedsLayout()
    intervalPie.setNeedsLayout()

    // Draw chord type over chord pie
    #if os(OSX)
      let majorAngle = chordNotes[1].circleStartAngle + 15 + 90
      let minorAngle = chordNotes[4].circleStartAngle + 15 + 90
      let dimAngle = chordNotes[6].circleStartAngle + 15 + 90
    #elseif os(iOS) || os(tvOS)
      let majorAngle = chordNotes[1].circleStartAngle + 15 - 90
      let minorAngle = chordNotes[4].circleStartAngle + 15 - 90
      let dimAngle = chordNotes[6].circleStartAngle + 15 - 90
    #endif

    majorArcText.text = NSAttributedString(
      string: "Major",
      attributes: [
        NSForegroundColorAttributeName: majorTextColor,
        NSFontAttributeName: CRFont.systemFont(ofSize: chordFontSize)
      ])
    majorArcText.angle = majorAngle
    majorArcText.radius = radius - chordTextTreshold
    majorArcText.frame = layer.bounds

    minorArcText.text = NSAttributedString(
      string: "Minor",
      attributes: [
        NSForegroundColorAttributeName: minorTextColor,
        NSFontAttributeName: CRFont.systemFont(ofSize: chordFontSize)
      ])
    minorArcText.angle = minorAngle
    minorArcText.radius = radius - chordTextTreshold
    minorArcText.frame = layer.bounds

    dimArcText.text = NSAttributedString(
      string: "Dim",
      attributes: [
        NSForegroundColorAttributeName: diminishedTextColor,
        NSFontAttributeName: CRFont.systemFont(ofSize: chordFontSize)
      ])
    dimArcText.angle = dimAngle
    dimArcText.radius = radius - chordTextTreshold
    dimArcText.frame = layer.bounds
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
    case .diminished: return roman.isEmpty ? "" : "\(roman)°"
    default: return roman
    }
  }

  // MARK: Redraw

  private func redraw() {
    #if os(OSX)
      needsLayout = true
    #elseif os(iOS) || os(tvOS)
      setNeedsLayout()
    #endif
  }

  // MARK: Selection

  public func selectNote(note: NoteType?) {
    selectedSlice?.isSelected = false
    guard let note = note
      else { return }
    let slice = circlePie.slices[note.circleIndex]
    slice.isSelected = true
    selectedSlice = slice
  }
}
