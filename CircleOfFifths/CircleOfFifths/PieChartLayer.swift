//
//  PieChartLayer.swift
//  CircleOfFifths
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

import UIKit

class PieChartSlice {
  var startAngle: CGFloat
  var endAngle: CGFloat
  var color: UIColor
  var highlightedColor: UIColor
  var disabledColor: UIColor
  var textLayer: CATextLayer
  var attributedString: NSAttributedString?

  var isEnabled: Bool = true
  var isSelected: Bool = false

  init(startAngle: CGFloat, endAngle: CGFloat, color: UIColor, highlightedColor: UIColor? = nil, disabledColor: UIColor? = nil, attributedString: NSAttributedString? = nil) {
    self.startAngle = startAngle
    self.endAngle = endAngle
    self.color = color
    self.highlightedColor = highlightedColor ?? color
    self.disabledColor = disabledColor ?? color
    self.attributedString = attributedString
    textLayer = CATextLayer()
  }
}

class PieChartLayer: CAShapeLayer {
  var slices: [PieChartSlice]
  var center: CGPoint
  var radius: CGFloat
  var labelPositionTreshold: CGFloat = 10
  var angleTreshold: CGFloat = -90

  private var sliceLayers = [CAShapeLayer]()

  init(radius: CGFloat, center: CGPoint, slices: [PieChartSlice]) {
    self.radius = radius
    self.center = center
    self.slices = slices
    super.init()
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    radius = 0
    center = .zero
    slices = []
    super.init(coder: aDecoder)
    setup()
  }

  override func layoutSublayers() {
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
      let color = slice.isEnabled ? (slice.isSelected ? slice.highlightedColor.cgColor : slice.color.cgColor) : slice.disabledColor.cgColor
      sliceLayer.fillColor = color
      sliceLayer.strokeColor = strokeColor
      sliceLayer.lineWidth = lineWidth

      // path
      let slicePath = UIBezierPath()
      slicePath.move(to: CGPoint(x: center.x, y: center.y))
      slicePath.addArc(
        withCenter: center,
        radius: radius,
        startAngle: toRadians(angle: slice.startAngle + angleTreshold),
        endAngle: toRadians(angle: slice.endAngle + angleTreshold),
        clockwise: true)
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
