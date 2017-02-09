//
//  ArcTextLayer.swift
//  CircleOfFifths
//
//  Created by Cem Olcay on 21/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

#if os(OSX)
  import AppKit
#elseif os(iOS) || os(tvOS)
  import UIKit
#endif

public class ArcTextLayer: CALayer {
  public var angle: CGFloat = 0
  public var radius: CGFloat = 0
  public var text: NSAttributedString? = nil {
    didSet {
      setup()
    }
  }
  private var textLayers = [CATextLayer]()

  public override func layoutSublayers() {
    super.layoutSublayers()
    draw()
  }

  private func setup() {
    guard let text = self.text else { return }

    for textLayer in textLayers {
      textLayer.removeFromSuperlayer()
    }
    textLayers = []

    for c in 0..<text.length {
      let textLayer = CATextLayer()
      textLayer.string = text.attributedSubstring(from: NSRange(c..<c+1))
      textLayer.alignmentMode = kCAAlignmentCenter
      textLayer.actions = ["position": NSNull() as CAAction]
      #if os(OSX)
        textLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
      #elseif os(iOS) || os(tvOS)
        textLayer.contentsScale = UIScreen.main.scale
      #endif

      addSublayer(textLayer)
      textLayers.append(textLayer)
    }
  }

  private func draw() {
    guard let text = self.text else { return }
    if !text.string.isEmpty, textLayers.isEmpty {
      setup()
    }

    var radAngle = toRadians(angle: angle)

    let textSize = text.boundingRect(
      with: CGSize(width: .max, height: .max),
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      context: nil)
      .integral
      .size

    let perimeter: CGFloat = 2 * .pi * radius
    let textAngle: CGFloat = textSize.width / perimeter * 2 * .pi

    var textRotation: CGFloat = 0
    var textDirection: CGFloat = 0

    if angle > toRadians(angle: 10), angle < toRadians(angle: 170) {
      // top string
      #if os(OSX)
        textRotation = 1.5 * .pi
        textDirection = 2 * .pi
        radAngle -= textAngle / 2
      #elseif os(iOS) || os(tvOS)
        textRotation = 0.5 * .pi
        textDirection = -2 * .pi
        radAngle += textAngle / 2
      #endif
    } else {
      // bottom string
      #if os(OSX)
        textRotation = 0.5 * .pi
        textDirection = -2 * .pi
        radAngle += textAngle / 2
      #elseif os(iOS) || os(tvOS)
        textRotation = 1.5 * .pi
        textDirection = 2 * .pi
        radAngle -= textAngle / 2
      #endif
    }

    for textLayer in textLayers {
      let letter = textLayer.string as! NSAttributedString
      let charSize = letter.boundingRect(
        with: CGSize(width: .max, height: .max),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil)
        .integral
        .size

      let letterAngle = (charSize.width / perimeter) * textDirection
      let x = radius * cos(radAngle + (letterAngle / 2))
      let y = radius * sin(radAngle + (letterAngle / 2))

      textLayer.frame = CGRect(
        x: (frame.size.width / 2) - (charSize.width / 2) + x,
        y: (frame.size.height / 2) - (charSize.height / 2) + y,
        width: charSize.width,
        height: charSize.height)
      textLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: radAngle - textRotation))
      radAngle += letterAngle
    }
  }

  private func toRadians(angle: CGFloat) -> CGFloat {
    return angle * .pi / 180
  }
}
