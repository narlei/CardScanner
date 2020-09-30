//
//  ViewController.swift
//  CardScanner
//
//  Created by Narlei Moreira on 09/30/2020.
//  Copyright (c) 2020 Narlei Moreira. All rights reserved.
//

import UIKit
import CardScanner

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet var resultsLabel: UILabel!

    @IBAction func scanPaymentCard(_ sender: Any) {
        
        // Add NSCameraUsageDescription to your Info.plist
        let scannerView = CardScanner.getScanner { card, date, cvv in
            self.resultsLabel.text = "\(card) \(date) \(cvv)"
        }
        present(scannerView, animated: true, completion: nil)
    }
}
