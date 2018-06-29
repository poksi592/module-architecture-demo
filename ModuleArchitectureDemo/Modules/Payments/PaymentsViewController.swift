//
//  PaymentsViewController.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 22/05/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

class PaymentsViewController: StoryboardIdentifiableViewController {
    
    var presenter: PaymentsPresenter?
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var payButton: UIButton!
    
    @IBAction private func payButtonAction(_ sender: UIButton) {
        
        presenter?.pay(amount: amountTextField.text)
    }
}
