//
//  RatingDialog.swift
//  Pods-Stanwood_Dialog_iOS_Example
//
//  Created by Eugène Peschard on 05/01/2018.
//

import UIKit

open class RatingDialog {
    
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
    
    static func display() throws {
        let podBundle = Bundle(for: RatingDialog.self)
        let bundleURL = podBundle.url(forResource: "Stanwood_Dialog_iOS", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let overlay = bundle.loadNibNamed("RatingDialogView",
                                          owner: RatingDialog.builder().host,
                                          options: nil)
        guard let host = RatingDialog.builder().host else {
            throw RatingDialogError.dialogError("Missing presenter UIViewController to add the Rating Dialog as subView")
        }
        guard let appStoreURL = RatingDialog.builder().appStoreURL else {
            throw RatingDialogError.dialogError("Missing appStore URL where user should rate the app")
        }
        if let view = overlay?.first as? RatingDialogView {
            view.buildAd(over: host,
                         with: RatingDialog.builder().text1,
                         RatingDialog.builder().text2,
                         RatingDialog.builder().text3,
                         RatingDialog.builder().text4,
                         from: RatingDialog.builder().faceURL,
                         over: RatingDialog.builder().bannerURL,
                         link: appStoreURL,
                         tint: RatingDialog.builder().accentTint,
                         cancel: RatingDialog.builder().cancel,
                         accept: RatingDialog.builder().accept)
        }
    }
    
    /// Counts app launches and returns true if the count matches the provided value
    public static func shouldShow(onLaunch count: Int) -> Bool {
        appLaunches += 1
        return appLaunches == count
    }
    
    public struct Builder {
        /// key for storing the launches count on `UserDefaults`
        private let appStarts = "numberOfAppStarts"
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
        
        /// The `UIViewController` where the overlay ad view will be added as a subview
        var host: UIViewController?
        
        /**
         Sets the text for the first paragraph
         
         - parameter paragraph1: text for the first paragraph (may include `\n`)
         */
        public func set(paragraph1: String) -> Builder {
            var builder = self
            builder.text1 = paragraph1
            return builder
        }
        
        /**
         Sets the text for the second paragraph
         
         - parameter paragraph2: text for the second paragraph (may include `\n`)
         
         - version: 0.6.1
         */
        public func set(paragraph2: String) -> Builder {
            var builder = self
            builder.text2 = paragraph2
            return builder
        }
        
        /**
         Sets the text for the third paragraph
         
         - parameter paragraph3: text for the third paragraph (may include `\n`)
         
         - version: 0.6.1
         */
        public func set(paragraph3: String) -> Builder {
            var builder = self
            builder.text3 = paragraph3
            return builder
        }
        
        /**
         Sets the text for the fourth paragraph
         
         - parameter paragraph4: text for the fourth paragraph (may include `\n`)
         
         - version: 0.6.1
         */
        public func set(paragraph4: String) -> Builder {
            var builder = self
            builder.text4 = paragraph4
            return builder
        }
        
        /**
         Sets the text for the Cancel button
         
         - parameter cancelText: text for Cancel button's label
         
         - version: 0.6.1
         */
        public func set(cancelText: String) -> Builder {
            var builder = self
            builder.cancel = cancelText
            return builder
        }
        
        /**
         Sets the text for the Accept button
         
         - parameter okText: text for Accept button's label
         
         - version: 0.6.1
         */
        public func set(okText: String) -> Builder {
            var builder = self
            builder.accept = okText
            return builder
        }
        
        /**
         Sets the URL for the Developer's face UIImage
         
         - parameter faceUrl: string to build the URL providing the image
         
         - version: 0.6.1
         */
        public func set(faceUrl: String) -> Builder {
            var builder = self
            if let builtURL = URL(string: faceUrl) {
                builder.faceURL = builtURL
            }
            return builder
        }
        
        /**
         Sets the URL for the Banner UIImage
         
         - parameter bannerUrl: string to build the URL providing the image
         
         - version: 0.6.1
         */
        public func set(bannerUrl: String) -> Builder {
            var builder = self
            if let builtURL = URL(string: bannerUrl) {
                builder.bannerURL = builtURL
            }
            return builder
        }
        
        /**
         Sets the URL for the App Store rating
         
         - parameter appID: Application's app ID, can be found in iTunes Connect
         
         - version: 0.6.1
         */
        public func buildAppStoreUrl(with appID: String) -> Builder {
            var builder = self
            if let builtURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review") {
                builder.appStoreURL = builtURL
            }
            return builder
        }
        
        /**
         Sets the URL for the App Store rating
         
         - parameter appStoreUrl: string to build the URL wher user can rate the app
         
         - version: 0.6.1
         */
        public func set(appStoreUrl: String) -> Builder {
            var builder = self
            if let builtURL = URL(string: appStoreUrl) {
                builder.appStoreURL = builtURL
            }
            return builder
        }
        
        /**
         Sets the tint color used for the cancel button's text and accept button's background color.
         
         - parameter tintColor: used for the accept and cancel buttons
         
         - version: 0.6.1
         */
        public func set(tintColor: UIColor?) -> Builder {
            var builder = self
            if let color = tintColor {
                builder.accentTint = color
            }
            return builder
        }
        
        /**
         Sets the presenter `UIViewController` where the overlay ad will be added as a subview
         
         - parameter presenter: used as host to add the ad overlay as subview
         
         - version: 0.6.1
         */
        public func set(presenter: UIViewController?) -> Builder {
            var builder = self
            if let viewController = presenter {
                builder.host = viewController
            }
            return builder
        }
        
        /**
         Returns the finalized RatingDialog object after setting all its properties
         
         - version: 0.6.1
         */
        public func build() throws {
            do {
                try RatingDialog.display()
            } catch {
                throw error
            }
        }
    }
}
