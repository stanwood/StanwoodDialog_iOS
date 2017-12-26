//
//  RateOverlayAd.swift
//  Stanwood_Dialog_iOS
//
//  Created by Eugène Peschard on 28/11/2017.
//  Copyright  © 2017 stanwood. All rights reserved.
//

import UIKit

class RateOverlayAd: UIView {
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var devProfile: UIImageView!
    @IBOutlet weak var rateMeText: UILabel!
    
    weak var tintColor: UIColor?
    weak var rateMe: URL?
    
    var overlayBannerContainer: UIView?
    
    init?(coder aDecoder: NSCoder) {
        super.init(coder: decoder)
        
        frame = CGRect(x: 0, y: 0, width: 300, height: 450)
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        
    }
    
    static func buildOverlayAd(onLaunch nth: Int,
                               with rateMeText: String,
                               from devProfile: UIImage,
                               over background: UIImage,
                               tint color: UIColor) {
        if UserDefaults.standard.integer(forKey: kNumberOfAppStartsKey) == nth  {
            background.image = background
            devProfile.image = devProfile
            rateMeText.text = rateMeText
            
            //rateMe = URL(string: )
            //tintColor.color = color
            
            //ADD BLACK SCREEN
            overlayBannerContainer = UIView(frame: CGRect(x: 0,
                                                          y: 0,
                                                          width: parent?.view.frame.size.width,
                                                          height: parent?.view.frame.size.height))
            overlayBannerContainer.backgroundColor = UIColor(white: 0, alpha: 0.5) as? CGColor
            frame.origin.x = (overlayBannerContainer.frame.size.width - frame.size.width) / 2
            frame.origin.y = (overlayBannerContainer.frame.size.height - frame.size.height) / 2
            overlayBannerContainer.addSubview(self)
            overlayBannerContainer.alpha = 0
            transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            parent?.view.addSubview(overlayBannerContainer)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
                overlayBannerContainer.alpha = 1
                transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { _ in }
            perform(#selector(close(_)), with: nil, afterDelay: 30)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            overlayBannerContainer.alpha = 0
            transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: {(_ finished: Bool) -> Void in
            overlayBannerContainer.removeFromSuperview()
        })
    }
    
    @IBAction func rateApp(_ sender: Any) {
        let rateMeUrl: String? = ConfigManager.shared().string(forKey: kKeyRateMeUrl)
        UIApplication.shared.openURL(URL(string: rateMeUrl!)!)
        let adManager = AdManager()
        adManager.closeOverlay()
    }
}
