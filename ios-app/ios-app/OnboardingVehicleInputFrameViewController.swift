//
//  OnboardingVehicleInputFrameViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class OnboardingVehicleInputFrameViewController: UIViewController {
    
    var showSkip = false
    var existingUser = false

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = CGFloat(Constants.round)
        skipButton.layer.cornerRadius = CGFloat(Constants.round)
        
        if DB.sharedInstance.currVehicleInfo == nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.modifyButtons),
                                                   name: DB.sharedInstance.newVehicleInfoNotification,
                                                   object: nil)
            
            if UserDefaults.standard.value(forKey: "ble_tracking") != nil {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.startBLEScan),
                                                       name: BLERouter.sharedInstance.sharedInstanceReadyNotification,
                                                       object: nil)
            }
        }
    }
    
    func startBLEScan() {
        BLERouter.sharedInstance.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DB.sharedInstance.currVehicleInfo == nil {
            if showSkip {
                skipButton.setTitle("Skip", for: .normal)
                skipButton.backgroundColor = doneButton.backgroundColor
            }
            
            doneButton.isHidden = true
        }
    }
    
    @IBAction func dismissVehicleForm(_ sender: Any) {
        if existingUser {
            _ = navigationController?.popViewController(animated: true)
        } else {
            self.performSegue(withIdentifier: "goToHome", sender: nil)
        }
    }
    
    @IBAction func vehicleSubmit(_ sender: Any) {
        if DB.sharedInstance.newVehicle {
            DB.sharedInstance.registerVehicle()
        }
        
        DB.sharedInstance.updateVehicleUsers()
        DB.sharedInstance.updateUserVehicles()
        
        //DB.sharedInstance.userVehicleKeys.insert(DB.sharedInstance.currVehicleInfo!["vin"]!)
        DB.sharedInstance.userVehicles[DB.sharedInstance.currVehicleInfo!["vin"]!] = [:]
        DB.sharedInstance.getUserVehicleInfo()
    }
    
    func modifyButtons() {
        if showSkip {
            skipButton.setTitle("Cancel", for: .normal)
            skipButton.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
        
        if !(DB.sharedInstance.userVehicles.keys.contains(DB.sharedInstance.currVehicleInfo!["vin"]!)) {
            doneButton.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCamera" {
            if let toViewController = segue.destination as? CameraFrameViewController {
                print("tabBarSegue = \(existingUser)")
                toViewController.tabBarSegue = existingUser
            }
        }
    }
}
