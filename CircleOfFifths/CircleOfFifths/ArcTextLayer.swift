//
//  ArcTextLayer.swift
//  CircleOfFifths
//
//  Created by Cem Olcay on 21/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

import UIKit

public class ArcTextLayer: CALayer {
  public var text: NSAttributedString? = nil
  public var angle: CGFloat = 0
  public var radius: CGFloat = 0
  private var textLayers = [CATextLayer]()

  public override func draw(in ctx: CGContext) {
    super.draw(in: ctx)
    draw()
  }
  
  public override func layoutSublayers() {
    super.layoutSublayers()
    draw()
  }

  private func draw() {
    for textLayer in textLayers {
      textLayer.removeFromSuperlayer()
    }
    textLayers = []

    drawCurvedString(
      text: text ?? NSAttributedString(string: ""),
      angle: angle,
      radius: radius)
  }

  private func drawCurvedString(text: NSAttributedString, angle: CGFloat, radius: CGFloat) {
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
      // bottom string
      textRotation = 0.5 * .pi
      textDirection = -2 * .pi
      radAngle += textAngle / 2
    } else {
      // top string
      textRotation = 1.5 * .pi
      textDirection = 2 * .pi
      radAngle -= textAngle / 2
    }

    for c in 0..<text.length {
      let letter = text.attributedSubstring(from: NSRange(c..<c+1))
      let charSize = letter.boundingRect(
        with: CGSize(width: .max, height: .max),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil)
        .integral
        .size

      let letterAngle = (charSize.width / perimeter) * textDirection
      let x = radius * cos(radAngle + (letterAngle / 2))
      let y = radius * sin(radAngle + (letterAngle / 2))

      let singleChar = drawText(
        on: self,
        text: letter,
        frame: CGRect(
          x: (frame.size.width / 2) - (charSize.width / 2) + x,
          y: (frame.size.height / 2) - (charSize.height / 2) + y,
          width: charSize.width,
          height: charSize.height))

      addSublayer(singleChar)
      textLayers.append(singleChar)

      singleChar.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: radAngle - textRotation))
      radAngle += letterAngle
    }
  }

  private func drawText(on layer: CALayer, text: NSAttributedString, frame: CGRect) -> CATextLayer {
    let textLayer = CATextLayer()
    textLayer.frame = frame
    textLayer.string = text
    textLayer.alignmentMode = kCAAlignmentCenter
    textLayer.contentsScale = UIScreen.main.scale
    return textLayer
  }

  private func toRadians(angle: CGFloat) -> CGFloat {
    return angle * .pi / 180
  }
}
