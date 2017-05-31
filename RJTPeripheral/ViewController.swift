//
//  ViewController.swift
//  RJTPeripheral
//
//  Created by Labs on 5/15/17.
//  Copyright © 2017 Tera Mo Labs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        BLEManager.sharedManager.startUp()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

