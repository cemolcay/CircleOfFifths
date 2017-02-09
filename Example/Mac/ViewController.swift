//
//  ViewController.swift
//  Mac
//
//  Created by Cem Olcay on 07/02/2017.
//
//

import Cocoa

class ViewController: NSViewController {

  override func viewDidLoad() {
    if #available(OSX 10.10, *) {
      super.viewDidLoad()
    } else {
      // Fallback on earlier versions
    }

    // Do any additional setup after loading the view.
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }


}

