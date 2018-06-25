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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toPayments() {
        
        guard let moduleUrl = URL(schema: "tandem",
                                  host: "payments",
                                  path: "/pay",
                                  parameters: ["storyboard": "PaymentsStoryboard",
                                               "presentationMode": "navigationStack",
                                               "amount": "123.00",
                                               "token": "hf120938h12983dh"])  else { return }
        
        ApplicationRouter.shared.open(url: moduleUrl) { (response, responseData, urlResponse, error) in
            
            //      completion()
        }
    }
}

