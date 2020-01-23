//
//  RatingDialog.swift
//  ePaper2_iOS
//
//  Created by AT on 1/22/20.
//  Copyright © 2020 stanwood GmbH. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
import StoreKit

public class RatingDialog: UIView {
    
    /// Starts the builder before calling the setters
    private static var mainBuilder = Builder()
    private static var dialog: RatingDialogView?
    
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
    
    
    /**
     Returns the finalized RatingDialog object after setting all its properties
     */
    static func showIfNeeded(_ ratingDialog: RatingDialogView, completion: RateMeStateBlock?) {
        
        launchCount += 1
        
        print("mainBuilder.requiredLaunchCount = ", mainBuilder.requiredLaunchCount)
        
        guard launchCount == mainBuilder.requiredLaunchCount else { return }
        
        
        
        //        ratingDialog.rootView = builder.rootView
        //        ratingDialog.appStoreURL = builder.appStoreURL
        //        ratingDialog.analytics = builder.analytics
        
        let root = RatingDialog.mainBuilder.rootView ?? UIApplication.shared.keyWindow!
        
        dialog = ratingDialog
        
        ratingDialog.show(in: root) { (state) in
            
            DispatchQueue.main.async {
                
                switch state {
                case .didSendToStore:
                    self.loadStoreFromID()
                case .didShowAppleReviewController:
                    self.loadAppleRateMe()
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
            /// TODO:- DONT FORGET - to handle error
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
            
            /// TODO:- DONT FORGET error log here
            guard let id = appID else { return nil }
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
        
        //        /**
        //         Sets the URL for the App Store rating
        //
        //         - parameter appStoreUrl: string to build the URL wher user can rate the app
        //         */
        //        private func set(appStoreUrl: String) -> Builder {
        //            if let builtURL = URL(string: appStoreUrl) {
        //                appStoreURL = builtURL
        //            }
        //            return self
        //        }
        
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
        
        public func set(useAppleRating: Bool) -> Builder {
            self.useAppleRating = useAppleRating
            return self
        }
        
        /// TODO:- DONT FORGET
        
        
        public func set(appID: String) -> Builder {
            self.appID = appID
            return self
        }
        //        /**
        //         Sets the analytics class
        //
        //         - parameter analytics: the analytics class
        //         */
        //        public func set(analytics: RatingDialogTracking) -> Builder {
        //            self.analytics = analytics
        //            return self
        //        }
        
        public func buildAndShowIfNeeded(_ completion: RateMeStateBlock? = nil) {
            
            //let bundle = Bundle(for: RatingDialogView.self)
            
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
            
            if !useAppleRating, appID == nil {
                  fatalError("To root the user to the store, please ensure to `set(appID: String)` otherwise set `useAppleRating` to true, and use the Apple `SKStoreReviewController`")
              }
                        
            RatingDialog.showIfNeeded(ratingDialog, completion: completion)
        }
        
        fileprivate func loadFromRemoteConfigIfPossible() {
            
            /// TODO:- DONT FORGET
            // Check what happens without an a firebase app init
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


fileprivate protocol LoadFromNib { }

extension UIView: LoadFromNib { }

fileprivate extension LoadFromNib where Self: UIView {
    
    static func loadFromNib(withFrame frame:CGRect? = nil, bundle: Bundle = Bundle.main) -> Self {
        
        let view = bundle.loadNibNamed(nibName, owner: nil, options: nil)!.last as! Self
        view.frame = frame ?? view.frame
        
        return view
    }
    
    static var nibName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last ?? ""
    }
}

class RateMeConfigurations {
    
    enum FirebaseConfig: String {
        
        case iosAppId = "ios_app_id"
        case rateDialogText4 = "rate_dialog_text_4"
        case rateDialogText3 = "rate_dialog_text_3"
        case rateDialogText2 = "rate_dialog_text_2"
        case rateDialogText = "rate_dialog_text"
        case rateDialogLaunchCount = "rate_dialog_launch_count"
        case rateDialogFaceUrl = "rate_dialog_face_url"
        case rateDialogBannerUrl = "rate_dialog_banner_url"
        case rateDialogCancelButton = "rate_dialog_cancel_button"
        case rateDialogOkButton = "rate_dialog_ok_button"
        
        static var isRemoteConfigActivated: Bool = false
        
        static func value<T: Any>(for key: FirebaseConfig) -> T? {
            let value = RemoteConfig.remoteConfig()[key.rawValue]
            
            switch T.self {
            case is String.Type: return value.stringValue as? T
            case is Data.Type: return value.dataValue as? T
            case is Bool.Type: return value.boolValue as? T
            case is Int.Type: return value.numberValue?.intValue as? T
            default: return nil
            }
        }
        
        public func value<T: Any>() -> T? {
            return FirebaseConfig.value(for: self)
        }
    }
}



