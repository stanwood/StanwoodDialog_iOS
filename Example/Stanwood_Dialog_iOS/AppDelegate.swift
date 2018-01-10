//
//  AppDelegate.swift
//  Stanwood_Dialog_iOS
//
//  Created by epeschard on 01/03/2018.
//  Copyright (c) 2018 epeschard. All rights reserved.
//

import UIKit
import StanwoodDialog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        buildRatingDialog()
        
        if let vc = window?.rootViewController as? ViewController {
            vc.updateUI()
        }
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func buildRatingDialog() {
        if RatingDialog.shouldShow(onLaunch: 5) {
            let text1 = "Hi,\nich bin Hannes, der Entwicker\nvon dieser app."
            let text2 = "Kleine App-Entwicker wie wir leben von gutten Bewertungen im App-Store."
            let text3 = "Wenn Ihnen unsere App gefallt dann bewertend Sie uns doch bitte."
            let text4 = "Sternchen reichen - dauert nur 1 Minute."
            
            let cancel = "Schließen"
            let accept = "App bewerten"
            
            let faceUrlString = "https://lh5.googleusercontent.com/-_w2wo1s6SkI/AAAAAAAAAAI/AAAAAAAAhMU/s78iSxXwVZk/photo.jpg"
            let bannerUrlString = "https://media.istockphoto.com/photos/plitvice-lakes-picture-id500463760?s=2048x2048"
            let appID = "1316369720"
        
            do {
                try RatingDialog.builder()
                    .set(paragraph1: text1)
                    .set(paragraph2: text2)
                    .set(paragraph3: text3)
                    .set(paragraph4: text4)
                    .set(cancelText: cancel)
                    .set(okText: accept)
                    .set(faceUrl: faceUrlString)
                    .set(bannerUrl: bannerUrlString)
                    .buildAppStoreUrl(with: appID)
                    .set(presenter: window?.rootViewController)
                    .build()
            } catch {
                print(error)
            }
        }
    }
}

