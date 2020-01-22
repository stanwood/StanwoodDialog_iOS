//
//  RatingDialogView.swift
//  ePaper2_iOS
//
//  Created by AT on 1/22/20.
//  Copyright © 2020 stanwood GmbH. All rights reserved.
//

import UIKit
import SDWebImage

public typealias RateSuccessBlock = (_ success: Bool) -> Void
public typealias ImageSuccessBlock = (_ image: UIImage?, _ error: String?) -> Void

/// :nodoc:
class RatingDialogView: UIView {
    
    var completion: RateSuccessBlock?
    
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
        completion?(true)
        hide()
    }
    
    @IBAction private func cancelSelected(_ sender: Any) {
        completion?(false)
        hide()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainTextView.isScrollEnabled = mainTextView.textExceedBounds
    }
    
    func show(in view: UIView) {
        
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


extension UIImageView {
    
//    func loadImage(from url: URL?,_ completion: ImageSuccessBlock? = nil) {
//
//        guard let imageURL = url else { return }
//
//        let defaultSession = URLSession(configuration: .default)
//
//        let request = URLRequest(url: imageURL)
//
//        let dataTask = defaultSession.dataTask(with: request, completionHandler: {
//            data, response, error in
//
//            if let error = error {
//
//                let errorMessage = "DataTask error: " + error.localizedDescription + "\n"
//                completion?(nil, errorMessage)
//
//            } else if let imageData = data,
//                let image = UIImage(data: imageData),
//                let response = response as? HTTPURLResponse,
//                response.statusCode == 200 {
//
//                DispatchQueue.main.async {
//                    self.image = image
//                    completion?(image, nil)
//                }
//            }else{
//                let errorMessage = "DataTask error: " + "Bad url response" + "\n"
//                completion?(nil, errorMessage)
//            }
//        })
//
//        dataTask.resume()
//    }
}


extension UITextView {
    
    var textExceedBounds: Bool {
        
        let sizeThatFitsTextView = sizeThatFits(CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT)))
        return sizeThatFitsTextView.height > bounds.height
    }
}

fileprivate extension UIView {
    
    func addConstraints(from view: UIView, top: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: view.topAnchor, constant: top),
                bottomAnchor.constraint(equalTo: view.bottomAnchor),
                leadingAnchor.constraint(equalTo: view.leadingAnchor),
                trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }
}
