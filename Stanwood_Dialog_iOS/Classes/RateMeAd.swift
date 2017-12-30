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
    
    @objc
    public func showAd(on launch: Int,
        over parent: UIViewController,
        with rateMeText: String?,
        from devProfile: UIImage,
        over background: UIImage,
        tint accentTint: UIColor) {
        if UserDefaults.standard.integer(forKey: RateMeAd.appStartCount) == launch  {
            
            devsBannerUI.image = background
            devProfileUI.image = devProfile
            if let dialog = rateMeText {
                rateMeTextUI.text = dialog
            }
            rateMeTextUI.sizeToFit()
            rateMeTextUI.numberOfLines = 0
            
            
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
        if let rating = URL(string: "rate_me_url") {
            UIApplication.shared.openURL(rating)
        }
        closeOverlayAd(self)
    }
}
