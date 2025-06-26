//
//  ViewController.swift
//  SwiftCalc
//
//  Created by Aidan Gleeson on 26/06/2025.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func numberPressed(_ sender: UIButton) {
        if let number = sender .currentTitle {
            print("Number pressed: \(number)")
        }
    }
    
    @IBAction func operatorPressed(_ sender: UIButton) {
        if let operation = sender.currentTitle {
            print("Operator pressed: \(operation)")
        }
    }
    
}

