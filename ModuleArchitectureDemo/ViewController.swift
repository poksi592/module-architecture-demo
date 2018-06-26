//
//  ViewController.swift
//  APIClientArchitectureDemo
//
//  Created by Mladen Despotovic on 20/03/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Main Screen"
    }
    
    @IBAction func toPayments() {
        
        ApplicationServices.shared.pay(amount: 123.00, completion: {})
    }
}

