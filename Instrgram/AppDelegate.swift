//
//  AppDelegate.swift
//  Instrgram
//
//  Created by Ian Mao on 7/5/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        AVOSCloud.setApplicationId("BUNJIqD5cBtt9aiNFwLFXNfi-gzGzoHsz", clientKey: "pRpMr9EdGENGxzvvbCg2FMwm")
        
        AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        
//        let testObject = AVObject(className: "TestObject")
//        testObject.setObject("bar", forKey: "foo")
//        testObject.save()
        
        login()
        
        return true
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
    }

    func login() {
        // get data back from user defaults
        let username : String? = UserDefaults.standard.string(forKey: "username")
        
        // if logged in successfully before
        if username != nil {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
            window?.rootViewController = myTabBar
        
            
            // test
//            AVUser.current()?.follow("596af3bb1b69e6006cca9221") {
//                (success: Bool, error: Error?) in
//                if success {
//                    print("Succeeded in following ianyibin")
//                } else {
//                    print(error?.localizedDescription)
//                }
//            }
        
        }
        
    }
}

