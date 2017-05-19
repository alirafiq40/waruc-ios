//
//  userRegistrationFormViewController.swift
//  ios-app
//
//  Created by ishansaksena on 5/18/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import Eureka

class userRegistrationFormViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Sign Up")
            
            <<< TextRow() {
                $0.title = "Email"
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<String>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleEmail())
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.placeholder = "rick@getschwifty.com"
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            <<< PasswordRow() {
                $0.title = "Password"
                $0.add(rule: RuleMinLength(minLength: 8))
                //$0.add(rule: RuleMaxLength(maxLength: 13))
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            <<< PasswordRow() {
                $0.title = "Retype Password"
                $0.add(rule: RuleMinLength(minLength: 8))
                //$0.add(rule: RuleMaxLength(maxLength: 13))
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Login"
                }
                .cellSetup() { cell, row in
                    cell.backgroundColor = UIColor.clear
                }
                .onCellSelection { [weak self] (cell, row) in
                    print("Logging In")
        }
    }
}