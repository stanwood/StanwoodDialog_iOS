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
        
    }
    
    open class Builder {
        /// key for storing the launches count on `UserDefaults`
        private let appStarts = "numberOfAppStarts"
        /// counts the number of launches
        private var appLaunches = 0
        
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
        var tintColor = UIColor.blue
        
        /// The `UIViewController` where the overlay ad view will be added as a subview
        var presenter = UIViewController() {
            didSet {
                tintColor = presenter.view.tintColor
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
         
         - parameter body: text for the first paragraph (may include `\n`)
         */
        public func setText1(body: String) -> Builder {
            text1 = body
            return self
        }
        
        /**
         Sets the text for the second paragraph
         
         - parameter body: text for the second paragraph (may include `\n`)
         */
        public func setText2(body: String) -> Builder {
            text2 = body
            return self
        }
        
        /**
         Sets the text for the third paragraph
         
         - parameter body: text for the third paragraph (may include `\n`)
         */
        public func setText3(body: String) -> Builder {
            text3 = body
            return self
        }
        
        /**
         Sets the text for the fourth paragraph
         
         - parameter body: text for the fourth paragraph (may include `\n`)
         */
        public func setText4(body: String) -> Builder {
            text4 = body
            return self
        }
        
        /**
         Sets the text for the Cancel button
         
         - parameter text: text for Cancel button's label
         */
        public func setCancelText(text: String) -> Builder {
            cancel = text
            return self
        }
        
        /**
         Sets the text for the Accept button
         
         - parameter text: text for Accept button's label
         */
        public func setOkText(text: String) -> Builder {
            accept = text
            return self
        }
        
        /**
         Sets the URL for the Developer's face UIImage
         
         - parameter text: string to build the URL providing the image
         */
        public func setFaceUrl(text: String) -> Builder {
            if let builtURL = URL(string: text) {
                faceURL = builtURL
            }
            return self
        }
        
        /**
         Sets the URL for the Banner UIImage
         
         - parameter text: string to build the URL providing the image
         */
        public func setBannerUrl(text: String) -> Builder {
            if let builtURL = URL(string: text) {
                bannerURL = builtURL
            }
            return self
        }
        
        /**
         Sets the URL for the App Store rating
         
         - parameter appID: Application's app ID, can be found in iTunes Connect
         */
        public func buildAppStoreUrl(with appID: String) -> Builder {
            if let builtURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)") {
                appStoreURL = builtURL
            }
            return self
        }
        
        /**
         Sets the URL for the App Store rating
         
         - parameter text: string to build the URL wher user can rate the app
         */
        public func setAppStoreUrl(text: String) -> Builder {
            if let builtURL = URL(string: text) {
                appStoreURL = builtURL
            }
            return self
        }
        
        /**
         Sets the tint color used for the cancel button's text and accept button's background color.
         
         - parameter color: used for the accept and cancel buttons
         */
        public func setTintColor(color: UIColor?) -> Builder {
            if let color = color {
                tintColor = color
            }
            return self
        }
        
        /**
         Returns the initialized view with all the properties set
         */
        public func build() -> RatingDialog {
            //
            let bundle = Bundle(for: RatingDialogView.self)
            let overlay = bundle.loadNibNamed("RatingDialogView",
                                              owner: self,
                                              options: nil)
            let appStarts = "numberOfAppStarts"
            
            let appLaunches = UserDefaults.standard.integer(forKey: appStarts) + 1
            UserDefaults.standard.set(appLaunches, forKey: appStarts)
            //
            
            return RatingDialog(builder: self)
        }
        
        /**
         Initializes and presents the ad overlay on the nth launch
         
         - parameter launch: the count of app launches until the overlay ad is shown
         */
        public func showOn(launch count: Int) -> RatingDialog? {
            
            let bundle = Bundle(for: RatingDialogView.self)
            let overlay = bundle.loadNibNamed("RatingDialogView",
                                              owner: self,
                                              options: nil)
            
            appLaunches = UserDefaults.standard.integer(forKey: appStarts) + 1
            UserDefaults.standard.set(appLaunches, forKey: appStarts)
            
            if appLaunches == count,
                let ratingDialogView = overlay?.first as? RatingDialogView {
                
                ratingDialogView.buildAd(over: presenter.view.frame.size,
                                         with: text1, text2, text3, text4,
                                         from: faceURL,
                                         over: bannerURL,
                                         link: appStoreURL,
                                         tint: tintColor,
                                         cancel: cancel,
                                         accept: accept)
                return RatingDialog(builder: self)
            }
            
            return RatingDialog(builder: self)
        }
    }
}
