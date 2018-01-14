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

open class RatingDialog: RatingDialogPresenting {
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
    private var rootView: UIView!
    public var analytics: RatingDialogTracking?
    
    enum RatingDialogError: Error {
        case dialogError(String)
    }
    
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
    
    func display() {
        
        analytics?.track(event: .showDialog)
        
        let overlay = overlayView()
        overlay.hostViewController = self as RatingDialogPresenting
        
        overlay.buildAd(over: rootView!,
                     with: text1,
                     text2,
                     text3,
                     text4,
                     from: faceURL!,
                     over: bannerURL!,
                     tint: accentTint!,
                     cancel: cancelButtonText,
                     accept: acceptButtonText)
        
    }
    
    public func cancelButtonAction() {
        analytics?.track(event: .cancelAction)
    }
    
    public func acceptButtonAction() {
        analytics?.track(event: .acceptAction)
        UIApplication.shared.openURL(appStoreURL!)
    }
    
    public func timeout() {
        analytics?.track(event: .timeout)
    }
    
    /// Counts app launches and returns true if the count matches the provided value
    public static func shouldShow(onLaunch count: Int) -> Bool {
        appLaunches += 1
        return appLaunches == count
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
         
         - version: 0.6.3
         */
        public func set(paragraph2: String) -> Builder {
            text2 = paragraph2
            return self
        }
        
        /**
         Sets the text for the third paragraph
         
         - parameter paragraph3: text for the third paragraph (may include `\n`)
         
         - version: 0.6.3
         */
        public func set(paragraph3: String) -> Builder {
            text3 = paragraph3
            return self
        }
        
        /**
         Sets the text for the fourth paragraph
         
         - parameter paragraph4: text for the fourth paragraph (may include `\n`)
         
         - version: 0.6.3
         */
        public func set(paragraph4: String) -> Builder {
            text4 = paragraph4
            return self
        }
        
        /**
         Sets the text for the Cancel button
         
         - parameter cancelText: text for Cancel button's label
         
         - version: 0.6.3
         */
        public func set(cancelText: String) -> Builder {
            cancel = cancelText
            return self
        }
        
        /**
         Sets the text for the Accept button
         
         - parameter okText: text for Accept button's label
         
         - version: 0.6.3
         */
        public func set(okText: String) -> Builder {
            accept = okText
            return self
        }
        
        /**
         Sets the URL for the Developer's face UIImage
         
         - parameter faceUrl: string to build the URL providing the image
         
         - version: 0.6.3
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
         
         - version: 0.6.3
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
         
         - version: 0.6.3
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
         
         - version: 0.6.3
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
         
         - version: 0.6.3
         */
        public func set(tintColor: UIColor) -> Builder {
            accentTint = tintColor
            return self
        }
        
        /**
         Sets the rootView `UIView` where the overlay ad will be added as a subview
         
         - parameter rootView: used as host to add the ad overlay as subview
         
         - version: 0.6.3
         */
        public func set(rootView: UIView) -> Builder {
            self.rootView = rootView
            return self
        }
        
        /**
         Returns the finalized RatingDialog object after setting all its properties
         
         - version: 0.6.3
         */
        public func build() throws {
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
