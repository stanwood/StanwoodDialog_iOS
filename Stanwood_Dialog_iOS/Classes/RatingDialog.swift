//
//  RatingDialog.swift
//  StanwoodDialog_iOS
//
//  Copyright (c) 2018 stanwood GmbH
//
//  The MIT License (MIT)
//
//  Copyright (c) 2018 Stanwood GmbH (www.stanwood.io)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

@objc public protocol RatingDialogPresenting {
    func acceptButtonAction()
    func cancelButtonAction()
    func timeout()
}

@available(iOS 10.0, *)
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
    
    @objc public var objcAnalytics: SWDRatingDialogTracking?
    
    /// key for storing the launches count on `UserDefaults`
    private static let appStartsKey = "numberOfAppStarts"
    /// minutes between launches when consecutive launches will be ignored
    private static let minTimeBetweenLaunches: TimeInterval = 60*30
    
    
    /// counts the number of launches starting from 1
    static var appLaunches: Int {
        get {
            return UserDefaults.standard.value(forKey: appStartsKey) as? Int ?? 1
        }
        set {
            UserDefaults.standard.set(newValue, forKey: appStartsKey)
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
        if let urlAppStore = appStoreURL {
            UIApplication.shared.open(urlAppStore, options: [:], completionHandler: nil)
        }
    }
    
    /// Called when the timeout is reached with no tap on dialog buttons
    public func timeout() {
        analytics?.track(event: .timeout)
    }
    
    /**
     Counts app launches and returns true if the count matches the provided value
     When not in DEBUG, appLaunches need to be 30 min appart for counter to increase
     
     - onLaunch count: Int for the launch count on which we should present the Rating Dialog
     */
    @objc public static func shouldShow(onLaunch count: Int) -> Bool {

        if count < 0  {
            return true
        }
        
        let result = appLaunches == count

        #if DEBUG
            appLaunches += 1
        #else
            if let lastAppStart = UserDefaults.standard.value(forKey: "lastAppStart") as? TimeInterval,
                lastAppStart > minTimeBetweenLaunches {
                appLaunches += 1
            }
        #endif
            
        UserDefaults.standard.set(Date.timeIntervalSinceReferenceDate, forKey: "lastAppStart")
        return result
    }
    
    /// Resets the launch count to zero
    public static func clearLaunchCount() {
        appLaunches = 0
    }
    
    /// Decreases the launch count by one
    public static func decreaseLaunchCount() {
        appLaunches -= 1
    }
    
    /// Initializer for Objective-C since Builder pattern is not supported
    @available(swift, obsoleted: 0.1)
    @objc
    public convenience init(paragraph1: NSString,
                     paragraph2: NSString,
                     paragraph3: NSString,
                     paragraph4: NSString,
                     cancel: NSString,
                     accept: NSString,
                     rootView: UIView,
                     accentTint: UIColor,
                     faceURL: NSURL,
                     bannerURL: NSURL,
                     appID: NSString,
                     analytics: SWDRatingDialogTracking
        ) {
        self.init()
        self.text1 = unescapeNewLines(in: paragraph1)
        self.text2 = unescapeNewLines(in: paragraph2)
        self.text3 = unescapeNewLines(in: paragraph3)
        self.text4 = unescapeNewLines(in: paragraph4)
        self.cancelButtonText = cancel as String
        self.acceptButtonText = accept as String
        self.rootView = rootView
        self.accentTint = accentTint
        self.faceURL = faceURL as URL
        self.bannerURL = bannerURL as URL
        self.appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review")
        self.objcAnalytics = analytics        
    }
    
    @available(swift, obsoleted: 0.1)
    @objc func objcDisplay() {
        display()
    }
    
    private func unescapeNewLines(in string: NSString) -> String {
        return string.replacingOccurrences(of: "\\n", with: "\n")
    }
    
    open class Builder {
        /// selected launch when we should present the ad
        var adLaunch = 5
        
        /// The text for the 1st paragraph in the ads body
        var text1 = "Hi there,\nmy name is John Appleseed,\nthe developer of this app."
        /// The text for the 2nd paragraph in the ads body
        var text2 = "Independent developers like me\nrely heavily on good ratings in the app store"
        /// The text for the 3rd paragraph in the ads body
        var text3 = "so that we can continue working on apps.\nIf you like this app, I'd be thrilled\nif you left a positive rating."
        /// The text for the 4th paragraph in the ads body
        var text4 = "the stars would be enough, it will only take a few seconds."
        
        /// The text for the cancel button label
        var cancel = "Cancel"
        /// The text for the accept button label
        var accept = "Rate the App"
        
        /// The URL for the image to be displayed profile image in a circle
        var faceURL = URL(string: "https://lh5.googleusercontent.com/-_w2wo1s6SkI/AAAAAAAAAAI/AAAAAAAAhMU/s78iSxXwVZk/photo.jpg")!
        /// The URL for the image to be displayed as banner behind the profile image
        var bannerURL = URL(string: "https://d30x8mtr3hjnzo.cloudfront.net/creatives/41868f99932745608fafdd3a03072e99")!
        
        /// The URL for rating the app on the appStore
        var appStoreURL: URL?
        
        /// The tint color for the Accept and Cancel `UIButton`s
        var accentTint = UIColor.blue
        
        /// The `UIView` where the overlay ad view will be added as a subview
        var rootView: UIView!
        
        /// The analytics class
        var analytics: RatingDialogTracking?
      
        private func unescapeNewLines(in string: String) -> String {
            return string.replacingOccurrences(of: "\\n", with: "\n")
        }
        
        /**
         Sets the text for the first paragraph
         
         - parameter paragraph1: text for the first paragraph (may include `\n`)
         */
        public func set(paragraph1: String) -> Builder {
            text1 = unescapeNewLines(in: paragraph1)
            return self
        }
        
        /**
         Sets the text for the second paragraph
         
         - parameter paragraph2: text for the second paragraph (may include `\n`)
         */
        public func set(paragraph2: String) -> Builder {
            text2 = unescapeNewLines(in: paragraph2)
            return self
        }
        
        /**
         Sets the text for the third paragraph
         
         - parameter paragraph3: text for the third paragraph (may include `\n`)
         */
        public func set(paragraph3: String) -> Builder {
            text3 = unescapeNewLines(in: paragraph3)
            return self
        }
        
        /**
         Sets the text for the fourth paragraph
         
         - parameter paragraph4: text for the fourth paragraph (may include `\n`)
         */
        public func set(paragraph4: String) -> Builder {
            text4 = unescapeNewLines(in: paragraph4)
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
         Sets the analytics class
         
         - parameter analytics: the analytics class
         */
        public func set(analytics: RatingDialogTracking) -> Builder {
            self.analytics = analytics
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
            ratingDialog.analytics = analytics
            
            ratingDialog.display()
        }
    }
}
