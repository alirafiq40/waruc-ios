//
//  AppDelegate.swift
//  ios-app
//
//  Created by Nicholas Nordale on 4/1/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let newVehicleAlert = UIAlertController(title: "Found New Vehicle", message: "Would you like to register as a driver of this vehicle?", preferredStyle: UIAlertControllerStyle.alert)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyB4KKkw7xZWUYxbwtY_6Nlr5RXAf_0jzcU")
        
        FIRApp.configure()
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        // Uncomment this line to sign out before each session
        //try! FIRAuth.auth()!.signOut()
        
        if FIRAuth.auth()?.currentUser != nil {
            print("User is signed in")
            
            if UserDefaults.standard.value(forKey: "ble_tracking") == nil &&
                UserDefaults.standard.value(forKey: "location_tracking") == nil {
                UserDefaults.standard.setValue("on", forKey: "ble_tracking")
            }
            
            DB.sharedInstance.createSingleton()
            
            if UserDefaults.standard.value(forKey: "ble_tracking") != nil {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.startBLEScan),
                                                       name: BLERouter.sharedInstance.sharedInstanceReadyNotification,
                                                       object: nil)
            }
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.presentVehicleCreationAlert),
                                                   name: DB.sharedInstance.newVehicleAlertNotification,
                                                   object: nil)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
                let rootViewController = self.window?.rootViewController;
                rootViewController!.performSegue(withIdentifier: "authedAddNewVehicle", sender: nil)
                
            })
            newVehicleAlert.addAction(okAction)
            newVehicleAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
        }
        
        return true
    }
    
    func startBLEScan() {
        BLERouter.sharedInstance.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func presentVehicleCreationAlert() {
        if UIApplication.topViewController() is OnboardingVehicleInputFrameViewController ||
            UIApplication.topViewController() is OnboardingVehicleFormViewController {
            print("\nVehicle Onboarding Form is already displayed.. don't display the add vehicle alert")
        } else {
            if let topController = UIApplication.topViewController() {
                topController.present(self.newVehicleAlert, animated: true, completion: nil)
                DB.sharedInstance.showAddVehicleAlert = false
            }

        }

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ios_app")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


