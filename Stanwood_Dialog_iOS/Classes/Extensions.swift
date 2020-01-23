//
//  Extensions.swift
//  FirebaseABTesting
//
//  Created by AT on 1/23/20.
//

import Foundation
import UIKit

extension UITextView {
    
    var textExceedBounds: Bool {
        
        let sizeThatFitsTextView = sizeThatFits(CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT)))
        return sizeThatFitsTextView.height > bounds.height
    }
}

extension UIView {
    
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

protocol LoadFromNib { }

extension UIView: LoadFromNib { }

extension LoadFromNib where Self: UIView {
    
    static func loadFromNib(withFrame frame:CGRect? = nil, bundle: Bundle = Bundle.main) -> Self {
        
        let view = bundle.loadNibNamed(nibName, owner: nil, options: nil)!.last as! Self
        view.frame = frame ?? view.frame
        
        return view
    }
    
    static var nibName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last ?? ""
    }
}
