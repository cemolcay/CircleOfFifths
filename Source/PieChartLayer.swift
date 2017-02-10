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

public class PieChartSlice {
  public var startAngle: CGFloat
  public var endAngle: CGFloat
  public var color: CRColor
  public var highlightedColor: CRColor
  public var disabledColor: CRColor
  fileprivate var textLayer: CATextLayer
  public var attributedString: NSAttributedString?

  public var isEnabled: Bool = true
  public var isSelected: Bool = false

  public init(startAngle: CGFloat, endAngle: CGFloat, color: CRColor, highlightedColor: CRColor? = nil, disabledColor: CRColor? = nil, attributedString: NSAttributedString? = nil) {
    self.startAngle = startAngle
    self.endAngle = endAngle
    self.color = color
    self.highlightedColor = highlightedColor ?? color
    self.disabledColor = disabledColor ?? color
    self.attributedString = attributedString
    textLayer = CATextLayer()
    textLayer.actions = ["position": NSNull() as CAAction]
    textLayer.alignmentMode = kCAAlignmentCenter
    #if os(OSX)
      textLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
    #elseif os(iOS) || os(tvOS)
      textLayer.contentsScale = UIScreen.main.scale
    #endif
  }
}

public class PieChartLayer: CAShapeLayer {
  public var slices = [PieChartSlice]()
  public var center: CGPoint = .zero
  public var radius: CGFloat = 0

  public var labelPositionTreshold: CGFloat = 10

  #if os(OSX)
    public var angleTreshold: CGFloat = 90
  #elseif os(iOS) || os(tvOS)
    public var angleTreshold: CGFloat = -90
  #endif

  private var sliceLayers = [CAShapeLayer]()

  // MARK: Init

  public init(radius: CGFloat, center: CGPoint, slices: [PieChartSlice]) {
    super.init()
    self.radius = radius
    self.center = center
    self.slices = slices
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  public override init(layer: Any) {
    super.init(layer: layer)
    setup()
  }

  // MARK: Lifecycle

  public override func layoutSublayers() {
    super.layoutSublayers()
    draw()
  }

  // MARK: Setup

  private func setup() {
    for sliceLayer in sliceLayers {
      sliceLayer.sublayers?.forEach({ $0.removeFromSuperlayer() })
      sliceLayer.removeFromSuperlayer()
    }

    for slice in slices {
      let sliceLayer = CAShapeLayer()
      sliceLayer.addSublayer(slice.textLayer)
      addSublayer(sliceLayer)
      sliceLayers.append(sliceLayer)
    }
  }

 // MARK: Draw

  private func draw() {
    frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)

    for (index, sliceLayer) in sliceLayers.enumerated() {
      let slice = slices[index]

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
          startAngle: toRadians(angle: slice.startAngle + angleTreshold),
          endAngle: toRadians(angle: slice.endAngle + angleTreshold),
          clockwise: true)
      #endif
      slicePath.close()
      sliceLayer.path = slicePath.cgPath

      // text layer
      slice.textLayer.string = slice.attributedString

      // text position
      let teta = toRadians(angle: (slice.endAngle + slice.startAngle + (angleTreshold * 2)) / 2)
      let d = radius - labelPositionTreshold
      let x = center.x + (d * cos(teta))
      let y = center.y + (d * sin(teta))
      slice.textLayer.position = CGPoint(x: x, y: y)

      // text frame
      if let att = slice.attributedString {

        #if os(OSX)
          if #available(OSX 10.11, *) {
            slice.textLayer.frame.size = att.boundingRect(
              with: CGSize(width: .max, height: .max),
              options: [.usesLineFragmentOrigin, .usesFontLeading],
              context: nil)
              .size
          } else {
            slice.textLayer.frame.size = att.string.boundingRect(
              with: CGSize(width: .max, height: .max),
              options: [.usesLineFragmentOrigin, .usesFontLeading],
              attributes: att.attributes(
                at: 0,
                effectiveRange: nil))
              .size
          }
        #elseif os(iOS) || os(tvOS)
          slice.textLayer.frame.size = att.boundingRect(
            with: CGSize(width: .max, height: .max),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
            .size
        #endif

      } else {
        slice.textLayer.frame.size = .zero
      }
    }
  }

  private func toRadians(angle: CGFloat) -> CGFloat {
    return angle * .pi / 180
  }
}
