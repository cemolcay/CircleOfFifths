//
//  ViewController.swift
//  CircleOfFifths
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

import UIKit
import MusicTheorySwift

class ViewController: UIViewController {
  @IBOutlet weak var circle: CircleOfFifths?

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let note = NoteType.all[Int(arc4random_uniform(UInt32(NoteType.all.count)))]
    circle?.selectNote(note: note)
  }
}

