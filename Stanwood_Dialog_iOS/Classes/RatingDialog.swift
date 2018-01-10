//
//  RatingDialog.swift
//  Pods-Stanwood_Dialog_iOS_Example
//
//  Created by Eugène Peschard on 05/01/2018.
//

import UIKit

open class RatingDialog {
    
    /// key for storing the launches count on `UserDefaults`
    private let appStarts = "numberOfAppStarts"
    /// counts the number of launches
    private var appLaunches = 0

    /// the URL for rating this app on the appStore
    var appStoreURL: URL?
    /// A container for the rating dialog
    var overlayBannerContainer: UIView?
    
    open static func builder() -> Builder {
        return Builder()
    }
    
    public init(builder: Builder) {
        if let launches = UserDefaults.standard.value(forKey: appStarts) as? Int {
            appLaunches = launches + 1
        } else {
            appLaunches = 1
        }
        UserDefaults.standard.set(appLaunches, forKey: appStarts)
        
        if appLaunches == builder.adLaunch {
            loadRatingDialog(with: builder)
        }
    }
    
    func loadRatingDialog(with builder: Builder) {
        let podBundle = Bundle(for: RatingDialog.self)
        let bundleURL = podBundle.url(forResource: "Stanwood_Dialog_iOS", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let overlay = bundle.loadNibNamed("RatingDialogView",
                                          owner: builder.host,
                                          options: nil)
        if let view = overlay?.first as? RatingDialogView {
            view.buildAd(over: builder.host,
                         with: builder.text1, builder.text2, builder.text3, builder.text4,
                         from: builder.faceURL,
                         over: builder.bannerURL,
                         link: builder.appStoreURL,
                         tint: builder.accentTint,
                         cancel: builder.cancel,
                         accept: builder.accept)
        }
    }
    
    open class Builder {
        /// key for storing the launches count on `UserDefaults`
        private let appStarts = "numberOfAppStarts"
        /// counts the number of launches
//        private var appLaunches = 0
        /// selected launch when we should present the ad
        var adLaunch = 5
        
        /// The text for the 1st paragraph in the ads body
        var text1 = "Hi,\nich bin Hannes, der Entwicker\nvon ON AIR."
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
        var appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id1316369720")!
        
        /// The tint color for the Accept and Cancel `UIButton`s
        var accentTint = UIColor.blue
        
        /// The `UIViewController` where the overlay ad view will be added as a subview
        var host = UIViewController() {
            didSet {
                accentTint = host.view.tintColor
            }
        }
        
        /**
         Starter method to start chaining commands
         */
        public func builder() -> RatingDialog {
            return RatingDialog(builder: self)
        }
        
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
         
         - version: 0.6.0
         */
        public func set(paragraph2: String) -> Builder {
            text2 = paragraph2
            return self
        }
        
        /**
         Sets the text for the third paragraph
         
         - parameter paragraph3: text for the third paragraph (may include `\n`)
         
         - version: 0.6.0
         */
        public func set(paragraph3: String) -> Builder {
            text3 = paragraph3
            return self
        }
        
        /**
         Sets the text for the fourth paragraph
         
         - parameter paragraph4: text for the fourth paragraph (may include `\n`)
         
         - version: 0.6.0
         */
        public func set(paragraph4: String) -> Builder {
            text4 = paragraph4
            return self
        }
        
        /**
         Sets the text for the Cancel button
         
         - parameter cancelText: text for Cancel button's label
         
         - version: 0.6.0
         */
        public func set(cancelText: String) -> Builder {
            cancel = cancelText
            return self
        }
        
        /**
         Sets the text for the Accept button
         
         - parameter okText: text for Accept button's label
         
         - version: 0.6.0
         */
        public func set(okText: String) -> Builder {
            accept = okText
            return self
        }
        
        /**
         Sets the URL for the Developer's face UIImage
         
         - parameter faceUrl: string to build the URL providing the image
         
         - version: 0.6.0
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
         
         - version: 0.6.0
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
         
         - version: 0.6.0
         */
        public func buildAppStoreUrl(with appID: String) -> Builder {
            if let builtURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)") {
                appStoreURL = builtURL
            }
            return self
        }
        
        /**
         Sets the URL for the App Store rating
         
         - parameter appStoreUrl: string to build the URL wher user can rate the app
         
         - version: 0.6.0
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
         
         - version: 0.6.0
         */
        public func set(tintColor: UIColor?) -> Builder {
            if let color = tintColor {
                accentTint = color
            }
            return self
        }
        
        /**
         Sets the presenter `UIViewController` where the overlay ad will be added as a subview
         
         - parameter presenter: used as host to add the ad overlay as subview
         
         - version: 0.6.0
         */
        public func set(presenter: UIViewController?) -> Builder {
            if let viewController = presenter {
                host = viewController
                accentTint = host.view.tintColor
            }
            return self
        }
        
        /**
         Returns the finalized RatingDialog object after setting all its properties
         
         - version: 0.6.0
         */
        public func build() {
            _ = RatingDialog(builder: self)
        }
        
//        /**
//         Initializes and presents the ad overlay on the nth launch
//
//         - parameter launch count: the count of app launches until the overlay ad is shown
//
//         - version: 0.6.0
//         */
//        public func showOn(launch count: Int) {
//
//            let bundle = Bundle(for: RatingDialogView.self)
//            let overlay = bundle.loadNibNamed("RatingDialogView",
//                                              owner: self,
//                                              options: nil)
//
//
//
//            if appLaunches == count,
//                let ratingDialogView = overlay?.first as? RatingDialogView {
//
//                ratingDialogView.buildAd(over: host,
//                                         with: text1, text2, text3, text4,
//                                         from: faceURL,
//                                         over: bannerURL,
//                                         link: appStoreURL,
//                                         tint: accentTint,
//                                         cancel: cancel,
//                                         accept: accept)
//            }
//        }
        
        /**
         Sets the selected launch on which we want the `RatingDialog` ad to be shown
         
         - parameter launchCount: app launch count on which we will present the ad
         
         - version: 0.6.0
         */
        public func set(launchCount: Int) -> Builder {
            adLaunch = launchCount
            return self
        }
    }
}
