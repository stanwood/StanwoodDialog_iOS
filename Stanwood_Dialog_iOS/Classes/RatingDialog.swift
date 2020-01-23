
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
import FirebaseRemoteConfig
import StoreKit

public class RatingDialog: UIView {
    
    private static var mainBuilder = Builder()
    private static var dialog: RatingDialogView?
    
    /// Starts the builder before calling the setters
    public static func builder() -> Builder {
        mainBuilder.loadFromRemoteConfigIfPossible()
        return mainBuilder
    }
    
    private struct Key {
        static let appLaunches = "com.stanwood.io.rateMe.appLaunches"
    }
    
    private static var launchCount: Int {
        get{
            let defaults = UserDefaults.standard
            defaults.register(defaults: [Key.appLaunches : 0])
            return defaults.integer(forKey: Key.appLaunches)
        }set{
            UserDefaults.standard.set(newValue, forKey: Key.appLaunches)
        }
    }
    
    /// For testing or to prompt user again. This will set the launch count of the app to 0
    public static func resetLaunchCount() {
        launchCount = 0
    }
    
    
    /**
     Returns the finalized RatingDialog object after setting all its properties
     */
    static func showIfNeeded(_ ratingDialog: RatingDialogView, completion: RateMeStateBlock?) {
        
        launchCount += 1
                
        guard launchCount == mainBuilder.requiredLaunchCount else { return }
        
        let root = RatingDialog.mainBuilder.rootView ?? UIApplication.shared.keyWindow!
        
        dialog = ratingDialog
        
        ratingDialog.show(in: root) { (state) in
            
            DispatchQueue.main.async {
                
                switch state {
                case .didSendToStore:
                    self.loadStoreFromID()
                    ratingDialog.hide()
                case .didShowAppleReviewController:
                    self.loadAppleRateMe()
                    ratingDialog.hide()
                case .didCancel:
                    ratingDialog.hide()
                default:
                    break
                }
                
                completion?(state)
            }
        }
    }
    
    
    private static func loadAppleRateMe() {
        
        SKStoreReviewController.requestReview()
    }
    
    private static func loadStoreFromID() {
        
        guard
            let url = mainBuilder.appStoreURL
            else {
                // Should never get here
                /*
                 if !useAppleRating, appID == nil {
                    fatalError("To root the user to the store, please ensure to `set(appID: String)` otherwise set `useAppleRating` to true, and use the Apple `SKStoreReviewController`")
                }*/
                return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}



extension RatingDialog {
    
    open class Builder {
        /// selected launch when we should present the rate me
        var requiredLaunchCount = 5
        
        /// The text for the cancel button label
        var cancel = "Cancel"
        /// The text for the accept button label
        var accept = "Rate the App"
        
        /// The URL for the image to be displayed profile image in a circle
        var faceURL = URL(string: "https://lh5.googleusercontent.com/-_w2wo1s6SkI/AAAAAAAAAAI/AAAAAAAAhMU/s78iSxXwVZk/photo.jpg")!
        /// The URL for the image to be displayed as banner behind the profile image
        var bannerURL = URL(string: "https://d30x8mtr3hjnzo.cloudfront.net/creatives/41868f99932745608fafdd3a03072e99")!
        
        /// The URL for rating the app on the appStore
        var appStoreURL: URL? {
            
            guard let id = appID else {
                
                // Should never get here
                /*
                 if !useAppleRating, appID == nil {
                 fatalError("To root the user to the store, please ensure to `set(appID: String)` otherwise set `useAppleRating` to true, and use the Apple `SKStoreReviewController`")
                 }*/
                return nil
            }
            
            return buildAppStoreUrl(with: id)
        }
        
        /// The tint color for the Accept and Cancel `UIButton`s
        var accentTint = UIColor.darkGray.withAlphaComponent(0.7)
        
        /// The `UIView` where the overlay ad view will be added as a subview
        var rootView: UIView?
        
        
        /// Use Apple rate me or direct straight tot he store
        var useAppleRating = true
        
        var appID: String?
        
        /// The analytics class
        // var analytics: RatingDialogTracking?
        
        /// Debug mode flag
        private var isDebugMode: Bool = false
        
        
        
        private func unescapeNewLines(in string: String) -> String {
            return string.replacingOccurrences(of: "\\n", with: "\n")
        }
        
        
        var text1: String?
        var text2: String?
        var text3: String?
        var text4: String?
        var mainText: String {
            
            var text = ""
            
            if let first = text1 {
                text += (first)
            }
            
            if let second = text2 {
                text += ("\n\n\n" + second)
            }
            
            if let third = text3 {
                text += ("\n\n\n" + third)
            }
            
            if let fourth = text4 {
                text += ("\n\n\n" + fourth)
            }
            
            
            return text
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
        private func buildAppStoreUrl(with appID: String) -> URL? {
            
            if let builtURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review") {
                return builtURL
            }
            return nil
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
         Sets the requiredLaunchCount `Int` of the dialog
         
         - parameter requiredLaunchCount: Number of launches required before the dialog is shown
         */
        public func set(requiredLaunchCount: Int) -> Builder {
            self.requiredLaunchCount = requiredLaunchCount
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
         Sets `Bool` to determine whether a user user routed to the store or if the native `SKStoreReviewController`
         
         - parameter useAppleRating: as above
         */
        public func set(useAppleRating: Bool) -> Builder {
            self.useAppleRating = useAppleRating
            return self
        }
        
        /**
         Sets the appID `String` of the app from the store
         
         - parameter appID: ID of the app in the appstore
         */
        public func set(appID: String) -> Builder {
            self.appID = appID
            return self
        }
        
        /**
         Called at the end of setting all parameters. If the launch count matches the `requiredLaunchCount` then the dialog will be shown
         - Parameters:
         - completion : completes  a `RateMeStateBlock` that will hate current state in the form of a `RateMeState` enum value
         
         ### Usage Example: ###
         ````
         RatingDialog.builder()
                    .set(cancelText: "Cancel")
                    .set(paragraph1: "Some test Text at the top")
                    .set(tintColor: .yellow)
                    .set(useAppleRating: false)
                    .buildAndShowIfNeeded { (state) in
         
                         switch state {
                            case .didCancel:
                                print("didCancel")
                            case .didShowInitialRateMe:
                                print("didShowInitialRateMe")
                            case .didShowAppleReviewController:
                                print("didShowAppleReviewController")
                            case .didSendToStore:
                                print("didSendToStore")
                         }
         
         }
         
         ````
         */
        public func buildAndShowIfNeeded(_ completion: RateMeStateBlock? = nil) {
            
            let podBundle = Bundle(for: RatingDialogView.self)
            let bundleURL = podBundle.url(forResource: "Stanwood_Dialog_iOS", withExtension: "bundle")
            let bundle = Bundle(url: bundleURL!)!
            let ratingDialog: RatingDialogView = RatingDialogView.loadFromNib(bundle: bundle)
            
            
            ratingDialog.mainText = mainText
            ratingDialog.cancelButtonText = cancel
            ratingDialog.acceptButtonText = accept
            ratingDialog.faceURL = faceURL
            ratingDialog.bannerURL = bannerURL
            ratingDialog.accentColour = accentTint
            ratingDialog.rateMeType = useAppleRating ? .storeController : .storeReview
            
            if !useAppleRating, appID == nil {
                fatalError("To root the user to the store, please ensure to `set(appID: String)` otherwise set `useAppleRating` to true, and use the Apple `SKStoreReviewController`")
            }
            
            RatingDialog.showIfNeeded(ratingDialog, completion: completion)
        }
        
        fileprivate func loadFromRemoteConfigIfPossible() {
            
            appID = RateMeConfigurations.FirebaseConfig.iosAppId.value()
            
            text1 = RateMeConfigurations.FirebaseConfig.rateDialogText.value()
            text2 = RateMeConfigurations.FirebaseConfig.rateDialogText2.value()
            text3 = RateMeConfigurations.FirebaseConfig.rateDialogText3.value()
            text4 = RateMeConfigurations.FirebaseConfig.rateDialogText4.value()
            
            requiredLaunchCount = RateMeConfigurations.FirebaseConfig.rateDialogLaunchCount.value() ?? 0
            
            if let faceURLString: String = RateMeConfigurations.FirebaseConfig.rateDialogFaceUrl.value(), let url = URL(string: faceURLString) {
                faceURL = url
            }
            
            if let bannerURLString: String = RateMeConfigurations.FirebaseConfig.rateDialogBannerUrl.value(), let url = URL(string: bannerURLString) {
                bannerURL = url
            }
            
            cancel = RateMeConfigurations.FirebaseConfig.rateDialogCancelButton.value() ?? cancel
            accept = RateMeConfigurations.FirebaseConfig.rateDialogOkButton.value() ?? accept
        }
    }
}






