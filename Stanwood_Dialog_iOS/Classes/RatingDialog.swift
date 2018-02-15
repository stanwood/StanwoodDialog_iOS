//
//  RatingDialog.swift
//  Pods-Stanwood_Dialog_iOS_Example
//
//  Created by Eugène Peschard on 05/01/2018.
//

import UIKit

public protocol RatingDialogPresenting {
    func acceptButtonAction()
    func cancelButtonAction()
    func timeout()
}

@objc
public class RatingDialog: NSObject, RatingDialogPresenting {
    private var text1: String?
    private var text2: String?
    private var text3: String?
    private var text4: String?
    private var faceURL: URL?
    private var bannerURL: URL?
    private var appStoreURL: URL?
    private var accentTint: UIColor?
    private var cancelButtonText: String?
    private var acceptButtonText: String?
    private var rootView: UIView?
    public var analytics: RatingDialogTracking?
    
    /// key for storing the launches count on `UserDefaults`
    private static let appStarts = "numberOfAppStarts"
    /// counts the number of launches
    static var appLaunches: Int {
        get {
            return UserDefaults.standard.value(forKey: appStarts) as? Int ?? 1
        }
        set {
            UserDefaults.standard.set(newValue, forKey: appStarts)
        }
    }
    
    /// Starts the builder before calling the setters
    open static func builder() -> Builder {
        return Builder()
    }
    
    private func overlayView() -> RatingDialogView {
        let podBundle = Bundle(for: RatingDialog.self)
        let bundleURL = podBundle.url(forResource: "Stanwood_Dialog_iOS", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        return bundle.loadNibNamed("RatingDialogView",
                                          owner: rootView,
                                          options: nil)!.first as! RatingDialogView
    }
    
    private func display() {
        
        analytics?.track(event: .showDialog)
        
        let overlay = overlayView()
        overlay.hostViewController = self as RatingDialogPresenting
        
        do {
            try overlay.buildAd(over: rootView,
                                with: text1,
                                text2,
                                text3,
                                text4,
                                from: faceURL,
                                over: bannerURL,
                                tint: accentTint,
                                link: appStoreURL,
                                cancel: cancelButtonText,
                                accept: acceptButtonText)
        } catch {
            RatingDialog.decreaseLaunchCount()
            if let ratingDialog = error as? RatingDialogError {
                analytics?.log(error: ratingDialog)
            } else {
                print(error)
            }
        }
    }
    
    /// Called when the cancel (left side) button on the dialog view is tapped
    public func cancelButtonAction() {
        analytics?.track(event: .cancelAction)
    }
    
    /// Called when the OK (right side) button on the dialog view is tapped
    public func acceptButtonAction() {
        analytics?.track(event: .acceptAction)
        UIApplication.shared.openURL(appStoreURL!)
    }
    
    /// Called when the timeout is reached with no tap on dialog buttons
    public func timeout() {
        analytics?.track(event: .timeout)
    }
    
    /// Counts app launches and returns true if the count matches the provided value
    public static func shouldShow(onLaunch count: Int) -> Bool {
        if let lastAppStart = UserDefaults.standard.value(forKey: "lastAppStart") as? TimeInterval,
            lastAppStart > 1800.0 {
            appLaunches += 1
        }
        UserDefaults.standard.set(Date.timeIntervalSinceReferenceDate, forKey: "lastAppStart")
        return appLaunches == count
    }
    
    /// Resets the launch count to zero
    public static func clearLaunchCount() {
        appLaunches = 0
    }
    
    /// Decreases the launch count by one
    public static func decreaseLaunchCount() {
        appLaunches -= 1
    }
    
    open class Builder {
        /// selected launch when we should present the ad
        var adLaunch = 5
        
        /// The text for the 1st paragraph in the ads body
        var text1 = "Hi,\nich bin Hannes, der Entwicker\nvon dieser app."
        /// The text for the 2nd paragraph in the ads body
        var text2 = "Kleine App-Entwicker wie wir leben von gutten Bewertungen im App-Store."
        /// The text for the 3rd paragraph in the ads body
        var text3 = "Wenn Ihnen unsere App gefallt dann bewertend Sie uns doch bitte."
        /// The text for the 4th paragraph in the ads body
        var text4 = "Sternchen reichen - dauert nur 1 Minute."
        
        /// The text for the cancel button label
        var cancel = "Schließen"
        /// The text for the accept button label
        var accept = "App bewerten"
        
        /// The URL for the image to be displayed profile image in a circle
        var faceURL = URL(string: "https://lh5.googleusercontent.com/-_w2wo1s6SkI/AAAAAAAAAAI/AAAAAAAAhMU/s78iSxXwVZk/photo.jpg")!
        /// The URL for the image to be displayed as banner behind the profile image
        var bannerURL = URL(string: "https://media.istockphoto.com/photos/plitvice-lakes-picture-id500463760?s=2048x2048")!
        
        /// The URL for rating the app on the appStore
        var appStoreURL: URL?
        
        /// The tint color for the Accept and Cancel `UIButton`s
        var accentTint = UIColor.blue
        
        /// The `UIView` where the overlay ad view will be added as a subview
        var rootView: UIView!
        
        /**
         Sets the text for the first paragraph
         
         - parameter paragraph1: text for the first paragraph (may include `\n`)
         */
        public func set(paragraph1: String) -> Builder {
            text1 = paragraph1
            return self
        }
        
        /**
         Sets the text for the second paragraph
         
         - parameter paragraph2: text for the second paragraph (may include `\n`)
         */
        public func set(paragraph2: String) -> Builder {
            text2 = paragraph2
            return self
        }
        
        /**
         Sets the text for the third paragraph
         
         - parameter paragraph3: text for the third paragraph (may include `\n`)
         */
        public func set(paragraph3: String) -> Builder {
            text3 = paragraph3
            return self
        }
        
        /**
         Sets the text for the fourth paragraph
         
         - parameter paragraph4: text for the fourth paragraph (may include `\n`)
         */
        public func set(paragraph4: String) -> Builder {
            text4 = paragraph4
            return self
        }
        
        /**
         Sets the text for the Cancel button
         
         - parameter cancelText: text for Cancel button's label
         */
        public func set(cancelText: String) -> Builder {
            cancel = cancelText
            return self
        }
        
        /**
         Sets the text for the Accept button
         
         - parameter okText: text for Accept button's label
         */
        public func set(okText: String) -> Builder {
            accept = okText
            return self
        }
        
        /**
         Sets the URL for the Developer's face UIImage
         
         - parameter faceUrl: string to build the URL providing the image
         */
        public func set(faceUrl: String) -> Builder {
            if let builtURL = URL(string: faceUrl) {
                faceURL = builtURL
            }
            return self
        }
        
        /**
         Sets the URL for the Banner UIImage
         
         - parameter bannerUrl: string to build the URL providing the image
         */
        public func set(bannerUrl: String) -> Builder {
            if let builtURL = URL(string: bannerUrl) {
                bannerURL = builtURL
            }
            return self
        }
        
        /**
         Sets the URL for the App Store rating
         
         - parameter appID: Application's app ID, can be found in iTunes Connect
         */
        public func buildAppStoreUrl(with appID: String) -> Builder {
            
            if let builtURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review") {
                appStoreURL = builtURL
            }
            return self
        }
        
        /**
         Sets the URL for the App Store rating
         
         - parameter appStoreUrl: string to build the URL wher user can rate the app
         */
        public func set(appStoreUrl: String) -> Builder {
            if let builtURL = URL(string: appStoreUrl) {
                appStoreURL = builtURL
            }
            return self
        }
        
        /**
         Sets the tint color used for the cancel button's text and accept button's background color.
         
         - parameter tintColor: used for the accept and cancel buttons
         */
        public func set(tintColor: UIColor) -> Builder {
            accentTint = tintColor
            return self
        }
        
        /**
         Sets the rootView `UIView` where the overlay ad will be added as a subview
         
         - parameter rootView: used as host to add the ad overlay as subview
         */
        public func set(rootView: UIView) -> Builder {
            self.rootView = rootView
            return self
        }
        
        /**
         Returns the finalized RatingDialog object after setting all its properties         
         */
        public func build() {
            let ratingDialog = RatingDialog()
            ratingDialog.text1 = text1
            ratingDialog.text2 = text2
            ratingDialog.text3 = text3
            ratingDialog.text4 = text4
            ratingDialog.cancelButtonText = cancel
            ratingDialog.acceptButtonText = accept
            ratingDialog.rootView = rootView
            ratingDialog.accentTint = accentTint
            ratingDialog.faceURL = faceURL
            ratingDialog.bannerURL = bannerURL
            ratingDialog.appStoreURL = appStoreURL
            ratingDialog.display()
        }
    }
}
