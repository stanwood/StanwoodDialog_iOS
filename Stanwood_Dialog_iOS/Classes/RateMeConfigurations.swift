
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

import Foundation
import FirebaseRemoteConfig


/// TODO:- DONT FORGET
public enum RateMeState {
    case didShowInitialRateMe, didSendToStore, didShowAppleReviewController, didCancel
}
/// TODO:- DONT FORGET

enum RateMeType {
    case storeController, storeReview
}
/// TODO:- DONT FORGET


public typealias RateMeStateBlock = (_ state: RateMeState) -> Void
public typealias ImageSuccessBlock = (_ image: UIImage?, _ error: String?) -> Void


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
