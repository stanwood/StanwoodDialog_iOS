//
//  RatingDialog.swift
//  Pods-Stanwood_Dialog_iOS_Example
//
//  Created by Eugène Peschard on 05/01/2018.
//

import UIKit

@objc
public class RatingDialog: UIView {
    
    @IBOutlet weak var devsBannerUI: UIImageView!
    @IBOutlet weak var devProfileUI: UIImageView!
    @IBOutlet weak var rateMeTextUI: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    //    weak var accentTint: UIColor?
    let appStarts = "numberOfAppStarts"
    var appStoreURL: URL?
    var overlayBannerContainer: UIView?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        frame = CGRect(x: 0, y: 0, width: 300, height: 450)
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
    }
    
    let AppDelegate = UIApplication.shared.delegate
    
    /// View controller presenting the Rating Dialog overlay
    weak var presenter: UIViewController!
    
    /// Count of app launches
    public var appLaunchesCount = 0
    
    /**
     It adds a popup asking the user to rate the app on the app store
     
     - parameter launch: the count of app launches until the overlay ad is shown
     - parameter presenter: the `UIViewController` hosting the ad overlay
     - parameter rateMeText: the text displayed in the ad overlay's body
     - parameter devProfile: the developer's profile image displayed in a circle
     - parameter background: a background image displayed behind `devProfile`
     - parameter rateMeLink: the link to the appStore for rating
     - parameter accentTint: a `UIColor` for the buttons accent over white
     - parameter cancelText: a text for the cancel buton on the left
     - parameter acceptText: a text for the accept buton on the right
     
     -version: 0.5.1
     
     ## Usage Example ##
     ````
     var rateMessage: String? = ConfigManager.shared().string(forKey: kKeyRateMeDialog)
     var profileImage = UIImage(named: "RateMeProfile")
     var bannerImage = UIImage(named: "RateMeBackground")
     var accentColor: UIColor? = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.00)
     
     RateMeAd.show(on: 2,
     over: presenter,
     with: rateMessage,
     from: profileImage,
     over: bannerImage,
     tint: accentColor)
     ````
     */
    public class func showAd(on launch: Int,
                             over presenter: UIViewController,
                             with rateMeText: String?,
                             from devProfile: UIImage,
                             over background: UIImage,
                             link rateMeLink: URL,
                             tint accentTint: UIColor,
                             cancel cancelText: String?,
                             accept acceptText: String?) {
        let bundle = Bundle(for: RatingDialog.self)
        let overlay = bundle.loadNibNamed("RatingDialog",
                                          owner: self,
                                          options: nil)
        increaseAppLaunchCount()
        if let ratingDialog = overlay?.first as? RatingDialog {
            ratingDialog.showAd(on: launch,
                                over: presenter,
                                with: rateMeText,
                                from: devProfile,
                                over: background,
                                link: rateMeLink,
                                tint: accentTint,
                                cancel: cancelText,
                                accept: acceptText)
        }
    }
    
    public func increaseAppLaunchCount() {
        appLaunchesCount = UserDefaults.standard.integer(forKey: appStarts) + 1
        UserDefaults.standard.set(appLaunchesCount, forKey: appStarts)
    }
    
//    /**
//     It adds a popup asking the user to rate the app on the app store
//     
//     - parameter launch: the count of app launches until the overlay ad is shown
//     - parameter presenter: the `UIViewController` hosting the ad overlay
//     - parameter rateMeText: the text displayed in the ad overlay's body
//     - parameter devProfile: developer's profile image URL, displayed in a circle
//     - parameter background: banner image URL displayed behind `devProfile`
//     - parameter rateMeLink: the link to the appStore for rating
//     - parameter accentTint: a `UIColor` for the buttons accent over white
//     
//     ## Usage Example ##
//     ````
//     var rateMessage: String? = ConfigManager.shared().string(forKey: kKeyRateMeDialog)
//     var profileImage = UIImage(named: "RateMeProfile")
//     var bannerImage = UIImage(named: "RateMeBackground")
//     var accentColor: UIColor? = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.00)
//     
//     RateMeAd.show(on: 2,
//     over: presenter,
//     with: rateMessage,
//     from: profileImage,
//     over: bannerImage,
//     tint: accentColor)
//     ````
//     */
//    public class func showAd(on launch: Int,
//                             over presenter: UIViewController,
//                             with rateMeText: String?,
//                             from devProfile: URL,
//                             over background: URL,
//                             link rateMeLink: URL,
//                             tint accentTint: UIColor,
//                             cancel cancelText: String?,
//                             accept acceptText: String?) {
//        let bundle = Bundle(for: RatingDialog.self)
//        let overlay = bundle.loadNibNamed("RatingDialog",
//                                          owner: self,
//                                          options: nil)
//        if let ratingDialog = overlay?.first as? RatingDialog {
//            ratingDialog.showAd(on: launch,
//                                over: presenter,
//                                with: rateMeText,
//                                from: devProfile,
//                                over: background,
//                                link: rateMeLink,
//                                tint: accentTint)
//            ratingDialog.cancelButton.label.text = cancelText
//            ratingDialog.acceptButton.label.text = acceptText
//        }
//    }
    
    /**
     Given an instance of RatingDialog, it adds a popup asking the user to rate the app on the app store
     
     - parameter launch: the count of app launches until the overlay ad is shown
     - parameter presenter: the `UIViewController` hosting the ad overlay
     - parameter rateMeText: the text displayed in the ad overlay's body
     - parameter devProfile: the developer's profile image displayed in a circle
     - parameter background: a background image displayed behind `devProfile`
     - parameter rateMeLink: the link to the appStore for rating
     - parameter accentTint: a `UIColor` for the buttons accent over white
          
     ## Usage Example ##
     ````
     let bundle = Bundle(for: RatingDialog.self)
     let overlay = bundle.loadNibNamed("RatingDialog", owner: self, options: nil)
     let ratingDialog: RatingDialog? = overlay?.first
     
     let rateMessage: String? = ConfigManager.shared().string(forKey: kKeyRateMeDialog)
     let profileImage = UIImage(named: "RateMeProfile")
     let bannerImage = UIImage(named: "RateMeBackground")
     let appStoreURL = URL(string: "")
     let accentColor: UIColor? = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.00)
     
     RatingDialog.show(on: 2,
                       over: presenter,
                       with: rateMessage,
                       from: profileImage,
                       over: bannerImage,
                       link: appStoreURL,
                       tint: accentColor)
     ````
     */
    @objc
    public func showAd(on launch: Int,
                       over presenter: UIViewController,
                       with rateMeText: String?,
                       from devProfile: UIImage,
                       over background: UIImage,
                       link rateMeLink: URL,
                       tint accentTint: UIColor,
                       cancel cancelText: String?,
                       accept acceptText: String?) {
        if UserDefaults.standard.integer(forKey: appStarts) == launch  {
            
            devsBannerUI.image = background
            devProfileUI.image = devProfile
            if let dialog = rateMeText {
                let rateInvite = dialog.replacingOccurrences(of: "\\n", with: "\n")
                rateMeTextUI.text = rateInvite
            }
            rateMeTextUI.sizeToFit()
            rateMeTextUI.numberOfLines = 0
            
            appStoreURL = rateMeLink
            acceptButton.backgroundColor = accentTint
            acceptButton.setTitle(acceptText, forState: .Normal)
            cancelButton.tintColor = accentTint
            cancelButton.setTitle(cancelText, forState: .Normal)
            
            //ADD BLACK SCREEN
            overlayBannerContainer = UIView(frame: CGRect(x: 0.0,
                                                          y: 0.0,
                                                          width: presenter.view.frame.size.width,
                                                          height: presenter.view.frame.size.height))
            overlayBannerContainer?.backgroundColor = UIColor(white: 0, alpha: 0.5)
            guard let overlaySize = overlayBannerContainer?.frame.size else {
                return
            }
            frame.origin.x = (overlaySize.width - frame.size.width) / 2
            frame.origin.y = (overlaySize.height - frame.size.height) / 2
            overlayBannerContainer?.addSubview(self)
            overlayBannerContainer?.alpha = CGFloat(0.0)
            transform = CGAffineTransform(scaleX: CGFloat(1.2), y: CGFloat(1.2))
            
            presenter.view.addSubview(overlayBannerContainer!)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
                self.overlayBannerContainer?.alpha = CGFloat(1.0)
                self.transform = CGAffineTransform(scaleX: CGFloat(1.0), y: CGFloat(1.0))
            }) { _ in }
            perform(#selector(closeOverlayAd(_:)), with: nil, afterDelay: 30)
        }
    }
    
    @IBAction func closeOverlayAd(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            self.overlayBannerContainer?.alpha = CGFloat(0.0)
            self.transform = CGAffineTransform(scaleX: CGFloat(1.2), y: CGFloat(1.2))
        }, completion: {(_ finished: Bool) -> Void in
            self.overlayBannerContainer?.removeFromSuperview()
        })
    }
    
    @IBAction func rateApp(_ sender: Any) {
        
        if let storeURL = appStoreURL {
            UIApplication.shared.openURL(storeURL)
        }
        closeOverlayAd(self)
    }
}
