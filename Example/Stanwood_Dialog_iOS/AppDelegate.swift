//
//  AppDelegate.swift
//  StanwoodDialog_iOS
//
//  Copyright (c) 2018 stanwood GmbH
//  Distributed under MIT licence.
//

import UIKit
import StanwoodDialog
import StanwoodAnalytics

extension StanwoodAnalytics: RatingDialogTracking {
    public func log(error: RatingDialogError) {
        switch error {
        case .dialogError(let message):
            let trackingError = NSError(domain: "StanwoodDialog", code: 0, userInfo: ["LocalizedDescription":message])
            track(error: trackingError)
        }
    }
    
    public func track(event: RatingDialogEvent) {
        trackScreen(name: event.rawValue)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var analytics: StanwoodAnalytics?
    var dialogAnalytics: RatingDialogTracking?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let fabricTracker = FabricTracker.FabricBuilder(context: application, key: nil).build()
        let firebaseTracker = FirebaseTracker.FirebaseBuilder(context: application).build()
        
        let analyticsBuilder = StanwoodAnalytics.builder()
            .add(tracker: fabricTracker)
            .add(tracker: firebaseTracker)
        
        analytics = analyticsBuilder.build()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        buildRatingDialog()
        
        if let vc = window?.rootViewController as? ViewController {
            vc.updateUI()
        }
        
        let trackingParameters = TrackingParameters(eventName: "",
                                            itemId: nil,
                                            name: nil,
                                            description: nil,
                                            category: nil,
                                            contentType: "warning")
        
        analytics?.track(trackingParameters: trackingParameters)
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
            let bannerUrlString = "https://d30x8mtr3hjnzo.cloudfront.net/creatives/41868f99932745608fafdd3a03072e99"
            let appID = "1316369720"
        
            RatingDialog.builder()
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
            
            // RatingDialog.clearLaunchCount()
        }
    }
}

