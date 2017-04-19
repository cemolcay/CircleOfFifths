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
  public var text: NSAttributedString = NSAttributedString() { didSet { setup() }}
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
    CATransaction.setDisableActions(true)

    // Clean
    textLayers.forEach({ $0.removeFromSuperlayer() })
    textLayers = []

    // Create
    for c in 0..<text.length {
      let textLayer = CATextLayer()
      textLayer.string = text.attributedSubstring(from: NSRange(c..<c+1))
      textLayer.alignmentMode = kCAAlignmentCenter
      #if os(OSX)
        textLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
      #elseif os(iOS) || os(tvOS)
        textLayer.contentsScale = UIScreen.main.scale
      #endif

      addSublayer(textLayer)
      textLayers.append(textLayer)
    }
  }

  // MARK: Draw

  public override func layoutSublayers() {
    super.layoutSublayers()
    draw()
  }

  private func draw() {
    var radAngle = angle.radians

    #if os(OSX)
      var textSize = CGSize.zero
      if #available(OSX 10.11, *) {
        textSize = text.boundingRect(
          with: CGSize(width: .max, height: .max),
          options: [.usesLineFragmentOrigin, .usesFontLeading],
          context: nil)
          .integral
          .size
      } else {
        textSize = text.string.boundingRect(
          with: CGSize(width: .max, height: .max),
          options: [.usesLineFragmentOrigin, .usesFontLeading],
          attributes: text.attributes(
            at: 0,
            effectiveRange: nil))
          .integral
          .size
      }
    #elseif os(iOS) || os(tvOS)
      let textSize = text.boundingRect(
        with: CGSize(width: .max, height: .max),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil)
        .integral
        .size
    #endif

    let perimeter: CGFloat = 2 * .pi * radius
    let textAngle: CGFloat = textSize.width / perimeter * 2 * .pi

    var textRotation: CGFloat = 0
    var textDirection: CGFloat = 0

    if angle > CGFloat(10).radians, angle < CGFloat(170).radians {
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

      #if os(OSX)
        var charSize = CGSize.zero
        if #available(OSX 10.11, *) {
          charSize = letter.boundingRect(
            with: CGSize(width: .max, height: .max),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
            .integral
            .size
        } else {
          charSize = letter.string.boundingRect(
            with: CGSize(width: .max, height: .max),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: letter.attributes(
              at: 0,
              effectiveRange: nil))
            .integral
            .size
        }
      #elseif os(iOS) || os(tvOS)
        let charSize = letter.boundingRect(
          with: CGSize(width: .max, height: .max),
          options: [.usesLineFragmentOrigin, .usesFontLeading],
          context: nil)
          .integral
          .size
      #endif

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
}
