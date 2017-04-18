//
//  PieChartLayer.swift
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

public class PieChartSlice {
  public var startAngle: CGFloat
  public var endAngle: CGFloat
  public var color: CRColor
  public var highlightedColor: CRColor
  public var disabledColor: CRColor
  public var attributedString: NSAttributedString?
  public var isEnabled: Bool
  public var isSelected: Bool

  public init(
    startAngle: CGFloat = 0,
    endAngle: CGFloat = 0,
    color: CRColor = .white,
    highlightedColor: CRColor = .lightGray,
    disabledColor: CRColor = .darkGray,
    attributedString: NSAttributedString? = nil,
    isEnabled: Bool = true,
    isSelected: Bool = false) {

    self.startAngle = startAngle
    self.endAngle = endAngle
    self.color = color
    self.highlightedColor = highlightedColor
    self.disabledColor = disabledColor
    self.attributedString = attributedString
    self.isEnabled = isEnabled
    self.isSelected = isSelected
  }
}

public class PieChartLayer: CAShapeLayer {
  public var slices = [PieChartSlice]() {
    didSet {
      if oldValue.count == slices.count {
        setNeedsLayout()
      } else {
        setup()
      }
    }
  }

  public var center: CGPoint = .zero { didSet { setNeedsLayout() }}
  public var radius: CGFloat = 0 { didSet { setNeedsLayout() }}
  public var labelPositionTreshold: CGFloat = 10 { didSet { setNeedsLayout() }}

  #if os(OSX)
    public var angleTreshold: CGFloat = 90
  #elseif os(iOS) || os(tvOS)
    public var angleTreshold: CGFloat = -90
  #endif

  private var sliceLayers = [CAShapeLayer]()
  private var textLayers = [CATextLayer]()

  // MARK: Init

  public override init() {
    super.init()
    setup()
  }

  public override init(layer: Any) {
    super.init(layer: layer)
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  private func setup() {
    // Clean layers
    sliceLayers.forEach({ $0.removeFromSuperlayer() })
    sliceLayers = []
    textLayers.forEach({ $0.removeFromSuperlayer() })
    textLayers = []

    // Create layers
    for _ in 0..<slices.count {
      let sliceLayer = CAShapeLayer()
      sliceLayers.append(sliceLayer)
      addSublayer(sliceLayer)

      let textLayer = CATextLayer()
      #if os(OSX)
        textLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
      #elseif os(iOS) || os(tvOS)
        textLayer.contentsScale = UIScreen.main.scale
      #endif
      textLayers.append(textLayer)
      addSublayer(textLayer)
    }
  }

  // MARK: Draw

  public override func layoutSublayers() {
    super.layoutSublayers()
    draw()
  }

  private func draw() {
    for index in 0..<slices.count {
      let slice = slices[index]
      let sliceLayer = sliceLayers[index]
      let textLayer = textLayers[index]

      // slice layer
      let color = slice.isSelected ? slice.highlightedColor.cgColor : (slice.isEnabled ? slice.color.cgColor : slice.disabledColor.cgColor)
      sliceLayer.fillColor = color
      sliceLayer.strokeColor = strokeColor
      sliceLayer.lineWidth = lineWidth

      // path
      let slicePath = CRBezierPath()
      slicePath.move(to: CGPoint(x: center.x, y: center.y))
      #if os(OSX)
        slicePath.appendArc(
          withCenter: center,
          radius: radius,
          startAngle: slice.startAngle + angleTreshold,
          endAngle: slice.endAngle + angleTreshold,
          clockwise: false)
      #elseif os(iOS) || os(tvOS)
        slicePath.addArc(
          withCenter: center,
          radius: radius,
          startAngle: (slice.startAngle + angleTreshold).radians,
          endAngle: (slice.endAngle + angleTreshold).radians,
          clockwise: true)
      #endif
      slicePath.close()
      sliceLayer.path = slicePath.cgPath

      // text layer
      textLayer.string = slice.attributedString

      // text position
      let teta = ((slice.endAngle + slice.startAngle + (angleTreshold * 2)) / 2.0).radians
      let d = radius - labelPositionTreshold
      let x = center.x + (d * cos(teta))
      let y = center.y + (d * sin(teta))
      textLayer.position = CGPoint(x: x, y: y)

      // text frame
      if let att = slice.attributedString {
        var textSize = CGSize.zero

        #if os(OSX)
          if #available(OSX 10.11, *) {
            textSize = att.boundingRect(
              with: CGSize(width: .max, height: .max),
              options: [.usesLineFragmentOrigin, .usesFontLeading],
              context: nil)
              .size
          } else {
            textSize = att.string.boundingRect(
              with: CGSize(width: .max, height: .max),
              options: [.usesLineFragmentOrigin, .usesFontLeading],
              attributes: att.attributes(
                at: 0,
                effectiveRange: nil))
              .size
          }
        #elseif os(iOS) || os(tvOS)
          textSize = att.boundingRect(
            with: CGSize(width: .max, height: .max),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
            .size
        #endif

        textLayer.frame.size = textSize
      } else {
        textLayer.frame.size = .zero
      }
    }
  }
}
