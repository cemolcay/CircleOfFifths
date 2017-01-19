//
//  PieChartLayer.swift
//  CircleOfFifths
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

import Quartz
import CoreGraphics

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

public class PieChartSlice {
  public var startAngle: CGFloat
  public var endAngle: CGFloat
  public var color: UIColor
  public var highlightedColor: UIColor
  public var disabledColor: UIColor
  public var textLayer: CATextLayer
  public var attributedString: NSAttributedString?

  public var isEnabled: Bool = true
  public var isSelected: Bool = false

  public init(startAngle: CGFloat, endAngle: CGFloat, color: UIColor, highlightedColor: UIColor? = nil, disabledColor: UIColor? = nil, attributedString: NSAttributedString? = nil) {
    self.startAngle = startAngle
    self.endAngle = endAngle
    self.color = color
    self.highlightedColor = highlightedColor ?? color
    self.disabledColor = disabledColor ?? color
    self.attributedString = attributedString
    textLayer = CATextLayer()
    textLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
  }
}

public class PieChartLayer: CAShapeLayer {
  public var slices: [PieChartSlice]
  public var center: CGPoint
  public var radius: CGFloat
  public var labelPositionTreshold: CGFloat = 10
  public var angleTreshold: CGFloat = 90

  private var sliceLayers = [CAShapeLayer]()

  public init(radius: CGFloat, center: CGPoint, slices: [PieChartSlice]) {
    self.radius = radius
    self.center = center
    self.slices = slices
    super.init()
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    radius = 0
    center = .zero
    slices = []
    super.init(coder: aDecoder)
    setup()
  }

  public override func layoutSublayers() {
    draw()
  }

  private func setup() {
    for sliceLayer in sliceLayers {
      sliceLayer.removeFromSuperlayer()
    }

    for slice in slices {
      let sliceLayer = CAShapeLayer()
      sliceLayer.addSublayer(slice.textLayer)
      addSublayer(sliceLayer)
      sliceLayers.append(sliceLayer)
    }
  }

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
      let slicePath = UIBezierPath()
      slicePath.move(to: CGPoint(x: center.x, y: center.y))
      slicePath.appendArc(
        withCenter: center,
        radius: radius,
        startAngle: slice.startAngle + angleTreshold, // toRadians(angle: slice.startAngle + angleTreshold),
        endAngle: slice.endAngle + angleTreshold, // toRadians(angle: slice.endAngle + angleTreshold),
        clockwise: false)
      sliceLayer.path = slicePath.cgPath

      // text layer
      slice.textLayer.string = slice.attributedString
      slice.textLayer.alignmentMode = kCAAlignmentCenter

      // size
      if let att = slice.attributedString {
        slice.textLayer.frame.size = att.boundingRect(
          with: CGSize(width: .max, height: .max),
          options: .usesLineFragmentOrigin,
          context: nil).size
      } else {
        slice.textLayer.frame.size = .zero
      }

      // position
      let teta = toRadians(angle: (slice.endAngle + slice.startAngle + (angleTreshold * 2)) / 2)
      let d = radius - labelPositionTreshold
      let x = center.x + (d * cos(teta))
      let y = center.y + (d * sin(teta))
      slice.textLayer.position = CGPoint(x: x, y: y)
    }
  }

  private func toRadians(angle: CGFloat) -> CGFloat {
    return angle * .pi / 180
  }
}
