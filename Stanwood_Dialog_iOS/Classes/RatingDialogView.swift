//
//  RatingDialogView.swift
//  StanwoodDialog
//
//  Created by Eugène Peschard on 08/01/2018.
//

import UIKit
import PromiseKit

public class RatingDialogView: UIView {
    
    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var devFace: UIImageView!
    @IBOutlet weak var paragraph1: UILabel!
    @IBOutlet weak var paragraph2: UILabel!
    @IBOutlet weak var paragraph3: UILabel!
    @IBOutlet weak var paragraph4: UILabel!
    @IBOutlet weak var accept: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    /// the view controller that will be hosting the rating dialog overlay
    var hostViewController: RatingDialogPresenting!
    
    /// Container view to present the Rating Dialog overlay
    var overlayBannerContainer: UIView?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        frame = CGRect(x: 0, y: 0, width: 300, height: 450)
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
    }
    
    /**
     It adds a popup asking the user to rate the app on the app store
     
     - parameter presenter: the `UIViewController` hosting the ad overlay
     - parameter body1: the text displayed in the ad overlay's 1st paragraph
     - parameter body2: the text displayed in the ad overlay's 2nd paragraph
     - parameter body3: the text displayed in the ad overlay's 3rd paragraph
     - parameter body4: the text displayed in the ad overlay's 4th paragraph
     - parameter devProfile: the URL for the developer's profile image
     - parameter background: the URL for a banner image displayed behind `devProfile`
     - parameter rateMeLink: the link to the appStore for rating
     - parameter accentTint: a `UIColor` for the buttons accent over white
     - parameter cancelText: a text to be displayed in the cancel `UIButton`
     - parameter acceptText: a text to be displayed in the accept `UIButton`
     
     -version: 0.6.4
     */
    @objc
    dynamic func buildAd(over rootView: UIView,
                        with body1: String?,
                        _ body2: String?,
                        _ body3: String?,
                        _ body4: String?,
                        from devProfile: URL,
                        over background: URL,
                        tint accentTint: UIColor,
                        cancel cancelText: String?,
                        accept acceptText: String?) {

        paragraph1.text = body1 ?? ""
        paragraph2.text = body2 ?? ""
        paragraph3.text = body3 ?? ""
        paragraph4.text = body4 ?? ""
        
        when(fulfilled: [
            fetchImage(from: devProfile),
            fetchImage(from: background)
            ]).then { results -> Promise<Void> in
                guard let faceImage = results[0],
                    let bannerImage = results[1] else { return .void }
                
                self.buildAd(over: rootView,
                             with: body1, body2, body3, body4,
                             face: faceImage,
                             over: bannerImage,
                             tint: accentTint,
                             cancel: cancelText,
                             accept: acceptText)
                return .void
            }.catch { error in
                print(error.localizedDescription)
        }
    }
    
    private func fetchImage(from url: URL) -> Promise<UIImage?> {
        return Promise { fulfill, reject in
            let request = URLRequest(url: url)
            let session = URLSession.shared
            let dataPromise: URLDataPromise = session.dataTask(with: request)
            _ = dataPromise.asImage().then { image -> Void in
                fulfill(image)
            }.catch(execute: reject)
        }
    }
    
    /**
     It adds a popup asking the user to rate the app on the app store
     
     - parameter presenter: the `UIViewController` hosting the ad overlay
     - parameter body1: the text displayed in the ad overlay's 1st paragraph
     - parameter body2: the text displayed in the ad overlay's 2nd paragraph
     - parameter body3: the text displayed in the ad overlay's 3rd paragraph
     - parameter body4: the text displayed in the ad overlay's 4th paragraph
     - parameter devProfile: the UIImage for the developer's profile image
     - parameter background: the UIImage for a banner image displayed behind `devProfile`
     - parameter rateMeLink: the link to the appStore for rating
     - parameter accentTint: a `UIColor` for the buttons accent over white
     - parameter cancelText: a text to be displayed in the cancel `UIButton`
     - parameter acceptText: a text to be displayed in the accept `UIButton`
     
     -version: 0.6.4
     */
    
    @objc
    dynamic func buildAd(over rootView: UIView,
                         with body1: String?,
                         _ body2: String?,
                         _ body3: String?,
                         _ body4: String?,
                         face devProfile: UIImage,
                         over background: UIImage,
                         tint accentTint: UIColor,
                         cancel cancelText: String?,
                         accept acceptText: String?) {
        
        paragraph1.text = body1 ?? ""
        paragraph2.text = body2 ?? ""
        paragraph3.text = body3 ?? ""
        paragraph4.text = body4 ?? ""
        
        devFace.image = devProfile
        banner.image = background
        
        accept.backgroundColor = accentTint
        accept.setTitle(acceptText, for: .normal)
        cancel.tintColor = accentTint
        cancel.setTitle(cancelText, for: .normal)
        
        buildOverlayAd(with: rootView)
    }
    
    /**
     It builds the container view of a specified `size`
     
     - parameter size: the size of the overlay containing the ad
    
     - version: 0.6.4
     */
    func buildOverlayAd(with rootView: UIView) {
        overlayBannerContainer = UIView(frame: CGRect(x: 0.0,
                                                      y: 0.0,
                                                      width: rootView.frame.size.width,
                                                      height: rootView.frame.size.height))
        overlayBannerContainer?.backgroundColor = UIColor(white: 0, alpha: 0.5)
        guard let overlaySize = overlayBannerContainer?.frame.size else {
            return
        }
        frame.origin.x = (overlaySize.width - frame.size.width) / 2
        frame.origin.y = (overlaySize.height - frame.size.height) / 2
        overlayBannerContainer?.addSubview(self)
        overlayBannerContainer?.alpha = CGFloat(0.0)
        transform = CGAffineTransform(scaleX: CGFloat(1.2), y: CGFloat(1.2))
        
        rootView.addSubview(overlayBannerContainer!)
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            self.overlayBannerContainer?.alpha = CGFloat(1.0)
            self.transform = CGAffineTransform(scaleX: CGFloat(1.0), y: CGFloat(1.0))
        }) { _ in }
        perform(#selector(timeoutPresenting), with: nil, afterDelay: 30)
    }
    
    @objc func timeoutPresenting() {
        hostViewController.timeout()
        dismissView()
    }
    
    func dismissView() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            self.overlayBannerContainer?.alpha = CGFloat(0.0)
            self.transform = CGAffineTransform(scaleX: CGFloat(1.2), y: CGFloat(1.2))
        }, completion: {(_ finished: Bool) -> Void in
            self.overlayBannerContainer?.removeFromSuperview()
        })
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        hostViewController.cancelButtonAction()
        dismissView()
    }
    
    @IBAction func acceptButtonAction(_ sender: Any) {
        hostViewController.acceptButtonAction()
        dismissView()
    }
}

extension Promise {
    
    public static var void: Promise<Void> {
        return Promise<Void>(value: ())
    }
}
