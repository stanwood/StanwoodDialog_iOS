//
//  RateOverlayAd.swift
//  Stanwood_Dialog_iOS
//
//  Created by Eugène Peschard on 28/11/2017.
//  Copyright  © 2017 stanwood. All rights reserved.
//

import UIKit

@objc
public class RateMeAd: UIView {
    
    @IBOutlet weak var devsBannerUI: UIImageView!
    @IBOutlet weak var devProfileUI: UIImageView!
    @IBOutlet weak var rateMeTextUI: UILabel!
    @IBOutlet weak var open: UIButton!
    @IBOutlet weak var close: UIButton!
    
    
//    weak var accentTint: UIColor?
    static let appStartCount = "numberOfAppStarts"
    var appStoreURL: URL?
    var overlayBannerContainer: UIView?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        frame = CGRect(x: 0, y: 0, width: 300, height: 450)
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
    }
    
    let AppDelegate = UIApplication.shared.delegate
    weak var parent: UIViewController! {
        if UI_USER_INTERFACE_IDIOM() == .pad {
//            if let tabBarController = window?.rootViewController as? UITabBarController {
//                return tabBarController.selectedViewController as!
//            } else {
//                return
//            }
            return window?.rootViewController
        } else {
            return window?.rootViewController
        }
    }
    
    /**
     It adds a popup asking the user to rate the app on the app store
     
     - parameter launch: the count of app launches until the overlay ad is shown
     - parameter parent: the `UIViewController` hosting the ad overlay
     - parameter rateMeText: the text displayed in the ad overlay's body
     - parameter devProfile: the developer's profile image displayed in a circle
     - parameter background: a background image displayed behind `devProfile`
     - parameter rateMeLink: the link to the appStore for rating
     - parameter accentTint: a `UIColor` for the buttons accent over white
     
     - version: 0.4.0
     
     ## Usage Example ##
     ````
     var rateMessage: String? = ConfigManager.shared().string(forKey: kKeyRateMeDialog)
     var profileImage = UIImage(named: "RateMeProfile")
     var bannerImage = UIImage(named: "RateMeBackground")
     var accentColor: UIColor? = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.00)
     
     RateMeAd.show(on: 2,
                   over: parent,
                   with: rateMessage,
                   from: profileImage,
                   over: bannerImage,
                   tint: accentColor)
     ````
    */
    public class func showAd(on launch: Int,
                             over parent: UIViewController,
                             with rateMeText: String?,
                             from devProfile: UIImage,
                             over background: UIImage,
                             link rateMeLink: URL,
                             tint accentTint: UIColor) {
        let bundle = Bundle(for: RateMeAd.self)
        let overlay = bundle.loadNibNamed("RateMeAd",
                                          owner: self,
                                          options: nil)
        if let rateMeAd = overlay?.first as? RateMeAd {
            rateMeAd.showAd(on: launch,
                            over: parent,
                            with: rateMeText,
                            from: devProfile,
                            over: background,
                            link: rateMeLink,
                            tint: accentTint)
        }
    }
    
    /**
     Given an instance of RateMeAd, it adds a popup asking the user to rate the app on the app store
     
     - parameter launch: the count of app launches until the overlay ad is shown
     - parameter parent: the `UIViewController` hosting the ad overlay
     - parameter rateMeText: the text displayed in the ad overlay's body
     - parameter devProfile: the developer's profile image displayed in a circle
     - parameter background: a background image displayed behind `devProfile`
     - parameter rateMeLink: the link to the appStore for rating
     - parameter accentTint: a `UIColor` for the buttons accent over white
     
     - version: 0.4.0
     
     ## Usage Example ##
     ````
     var bundle = Bundle(for: RateMeAd.self)
     var overlay = bundle.loadNibNamed("RateMeAd", owner: self, options: nil)
     var rateMeAd: RateMeAd? = overlay?.first
     
     var rateMessage: String? = ConfigManager.shared().string(forKey: kKeyRateMeDialog)
     var profileImage = UIImage(named: "RateMeProfile")
     var bannerImage = UIImage(named: "RateMeBackground")
     var accentColor: UIColor? = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.00)
     
     RateMeAd.show(on: 2,
                   over: parent,
                   with: rateMessage,
                   from: profileImage,
                   over: bannerImage,
                   tint: accentColor)
     ````
     */
    @objc
    public func showAd(on launch: Int,
        over parent: UIViewController,
        with rateMeText: String?,
        from devProfile: UIImage,
        over background: UIImage,
        link rateMeLink: URL,
        tint accentTint: UIColor) {
        if UserDefaults.standard.integer(forKey: RateMeAd.appStartCount) == launch  {
            
            devsBannerUI.image = background
            devProfileUI.image = devProfile
            if let dialog = rateMeText {
                let rateInvite = dialog.replacingOccurrences(of: "\\n", with: "\n")
                rateMeTextUI.text = rateInvite
            }
            rateMeTextUI.sizeToFit()
            rateMeTextUI.numberOfLines = 0
            
            appStoreURL = rateMeLink
            open.backgroundColor = accentTint
            close.tintColor = accentTint
            
            //ADD BLACK SCREEN
            overlayBannerContainer = UIView(frame: CGRect(x: 0.0,
                                                          y: 0.0,
                                                          width: parent.view.frame.size.width,
                                                          height: parent.view.frame.size.height))
            overlayBannerContainer?.backgroundColor = UIColor(white: 0, alpha: 0.5)
            guard let overlaySize = overlayBannerContainer?.frame.size else {
                return
            }
            frame.origin.x = (overlaySize.width - frame.size.width) / 2
            frame.origin.y = (overlaySize.height - frame.size.height) / 2
            overlayBannerContainer?.addSubview(self)
            overlayBannerContainer?.alpha = CGFloat(0.0)
            transform = CGAffineTransform(scaleX: CGFloat(1.2), y: CGFloat(1.2))
            
            parent.view.addSubview(overlayBannerContainer!)
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
