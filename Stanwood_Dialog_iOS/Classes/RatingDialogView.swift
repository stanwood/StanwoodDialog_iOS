//
//  RatingDialogView.swift
//  ePaper2_iOS
//
//  Created by AT on 1/22/20.
//  Copyright © 2020 stanwood GmbH. All rights reserved.
//

import UIKit
import SDWebImage

/// :nodoc:
class RatingDialogView: UIView {
    
    private var completion: RateMeStateBlock?
    
    var rateMeType: RateMeType = .storeController
    
    var mainText: String? {
        didSet{
            mainTextView.text = mainText
        }
    }
    
    var cancelButtonText: String? {
        didSet{
            cancelButton.setTitle(cancelButtonText, for: .normal)
        }
    }
    
    var acceptButtonText: String? {
        didSet{
            rateMeButton.setTitle(acceptButtonText, for: .normal)
        }
    }
    
    var faceURL: URL? {
        didSet{
            faceImageView.sd_setImage(with: faceURL, completed: nil)
        }
    }
    
    var bannerURL: URL? {
        didSet{
            bannerimageView.sd_setImage(with: bannerURL, completed: nil)
        }
    }
    
    var accentColour: UIColor? {
        didSet{
            rateMeButton.backgroundColor = accentColour
            cancelButton.tintColor = accentColour
        }
    }
    
    
    @IBOutlet private weak var mainTextView: UITextView!
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var rateMeButton: UIButton!
    
    @IBOutlet private weak var faceImageView: UIImageView!
    @IBOutlet private weak var bannerimageView: UIImageView!
    
    
    @IBAction private func rateMeSelected(_ sender: Any) {
        
        switch rateMeType {
        case .storeReview:
            completion?(.didSendToStore)
        case .storeController:
            completion?(.didShowAppleReviewController)
        }
    }
    
    @IBAction private func cancelSelected(_ sender: Any) {
        completion?(.didCancel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainTextView.isScrollEnabled = mainTextView.textExceedBounds
    }
    
    func show(in view: UIView,_ completion: RateMeStateBlock? ) {
        
        self.completion = completion
        
        completion?(.didShowInitialRateMe)

        alpha = 0
        transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        view.addSubview(self)
        addConstraints(from: view)
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5) {
            
            self.alpha = 1
            self.transform = .identity
            self.layoutIfNeeded()
        }
    }
    
    func hide() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            self.alpha = 0
            self.superview?.layoutIfNeeded()

        }) { (_) in
            
            self.removeFromSuperview()
        }
    }
}


