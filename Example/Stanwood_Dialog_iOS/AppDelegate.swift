//
//  AppDelegate.swift
//  Stanwood_Dialog_iOS
//
//  Created by epeschard on 01/03/2018.
//  Copyright (c) 2018 epeschard. All rights reserved.
//

import UIKit
import StanwoodDialog
import StanwoodAnalytics

extension StanwoodAnalytics: RatingDialogTracking {
    public func track(event: RatingDialogEvent) {
        let trackingParams = TrackingParams(eventName: "RatingDialog", contentType: "info", lineNumber: nil, method: nil, file: nil, tag: nil)
        
        switch event {
        case .showDialog:
            track(event: TrackingEvent.showDialog, trackingParams: trackingParams)
        case .acceptAction:
            track(event: TrackingEvent.acceptAction, trackingParams: trackingParams)
        case .cancelAction:
            track(event: TrackingEvent.cancelAction, trackingParams: trackingParams)
        case .timeout:
            track(event: TrackingEvent.timeout, trackingParams: trackingParams)
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var analytics: StanwoodAnalytics?
    var dialogAnalytics: RatingDialogTracking?
    
    let bugFenderKey = "5Svt9b117yMmJDumCYZFgpSVnmoTSkD8"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let bugfenderTracker = BugfenderTracker.BugfenderBuilder(context: application, key: bugFenderKey)
            .setUIEventLogging(enable: true)
            .build()
        
        let crashlyticsTracker = CrashlyticsTracker.CrashlyticsBuilder(context: application, key: nil).build()
        let firebaseTracker = FirebaseTracker.FirebaseBuilder(context: application, key: nil).build()
        
        let analyticsBuilder = StanwoodAnalytics.builder()
            .add(tracker: bugfenderTracker)
            .add(tracker: crashlyticsTracker)
            .add(tracker: firebaseTracker)
        
        analytics = analyticsBuilder.build()
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
        
        let trackingParams = TrackingParams(eventName: "",
                                            itemId: nil,
                                            name: nil,
                                            description: nil,
                                            category: nil,
                                            contentType: "warning",
                                            lineNumber: 68,
                                            method: "didBecomeActive",
                                            file: "AppDelegate",
                                            tag: "App Lifecycle")
        
        analytics?.track(event: TrackingEvent.screen, trackingParams: trackingParams)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func buildRatingDialog() {
        if RatingDialog.shouldShow(onLaunch: 24) {
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
                    .set(analytics: analytics!)
                    .set(rootView: (window?.rootViewController?.view)!)
                    .build()
            } catch {
                print(error)
            }
        }
    }
}

