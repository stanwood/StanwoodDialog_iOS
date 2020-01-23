# StanwoodDialog

[![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)]()
[![iOS 10.3+](https://img.shields.io/badge/iOS-10.3+-EB7943.svg)]()
[![Pod Version](https://cocoapod-badges.herokuapp.com/l/StanwoodDialog/badge.png)]()
[![Maintainability](https://api.codeclimate.com/v1/badges/f34e56f2c699c367691a/maintainability)](https://codeclimate.com/github/stanwood/StanwoodDialog_iOS/maintainability) 
[![Build Status](https://app.bitrise.io/app/200a49178c1c4df4/status.svg?token=sfQNfpyzN4c_FAGGTefmqw&branch=master)](https://app.bitrise.io/app/200a49178c1c4df4)
[![License](https://cocoapod-badges.herokuapp.com/l/StanwoodDialog/badge.svg)](http://cocoapods.org/pods/StanwoodDialog) 
[![Build Status](https://travis-ci.org/stanwood/StanwoodDialog_iOS.svg?branch=master)](https://travis-ci.org/stanwood/StanwoodDialog_iOS)
[![Docs](https://img.shields.io/badge/docs-%E2%9C%93-blue.svg)](https://stanwood.github.io/StanwoodDialog_iOS/)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

StanwoodDialog_iOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'StanwoodDialog'
```

## Usage

Add `import StanwoodDialog` and call the method bellow from wherever you are calling `AppDelegate`'s `applicationDidBecomeAvailable`: 
If you wish to specify your string locally, you can add them here
```swift
    RatingDialog.builder()
            .set(paragraph1: "text1")
            .set(paragraph2: "text2")
            .set(paragraph3: "text3")
            .set(paragraph4: "text4")
            .set(cancelText: "cancel")
            .set(okText: "accept")
            .set(faceUrl: "faceUrlString")
            .set(bannerUrl: "bannerUrlString")
            .set(tintColor: .blue)
            .set(appID: "9876973263")
            .set(rootView: UIApplication.shared.keyWindow!)
            .buildAndShowIfNeeded { (state) in
                
                        switch state {
                        case .didCancel:
                            print("didCancel")
                        case .didShowInitialRateMe:
                            print("didShowInitialRateMe")
                        case .didShowAppleReviewController:
                            print("didShowAppleReviewController")
                        case .didSendToStore:
                            print("didSendToStore")
                        }
                
            }
```
Ideally you would be fetching each one of these parameters remotely. For instance, from Firebase RemoteConfig to do some A/B testing and/or from a service like lokalise.co to provide internationalization. 

If you want to use values direct from Firebase RemoteConfig, you can use the rquired keys below to clean up your code.





With completion, as little as:
```swift
    RatingDialog.builder().buildAndShowIfNeeded { (state) in
        
                switch state {
                case .didCancel:
                    print("didCancel")
                case .didShowInitialRateMe:
                    print("didShowInitialRateMe")
                case .didShowAppleReviewController:
                    print("didShowAppleReviewController")
                case .didSendToStore:
                    print("didSendToStore")
                }
        
    }
```
Without completion:
```swift
    RatingDialog.builder().buildAndShowIfNeeded()
```

Required RemoteConfig keys
```
"ios_app_id" - ID od application in the store
"rate_dialog_text" - First line of text
"rate_dialog_text_2" - Second line of text
"rate_dialog_text_3" - Third line of text
"rate_dialog_text_4" - Fourth line of text
"rate_dialog_launch_count" - Number of launches required until dialog is shown
"rate_dialog_face_url" - Url string to load a face image
"rate_dialog_banner_url" - Url string to load a banner image
"rate_dialog_cancel_button" - Cancel button title
"rate_dialog_ok_button" - Ok button title
```


If you don't have a URL for the profile and banner images, you may upload these to Firebase Storage (go to Store section in Firebase and click on [Upload Image]):
 * the profile image should be 300x300 pixels (this will cover the 3 variations for 100x100 points)
 * the banner image should be 300x1125 pixels (this will cover the 3 variations for 100x375 points)
 
 
 ## Test
 
Using a negative value in `RatingDialog.shouldShow(onLaunch: -1)` will result in the Rating Dialog being shown everytime.

Also, while in `Debug`, the launch count doesn't need 30 minutes from the last launch to increase its count. 


## Author

Eugène Peschard, eugene.peschard@stanwood.io

## License

StanwoodDialog is under MIT licence. See the [LICENSE](https://github.com/stanwood/Stanwood_Dialog_iOS/blob/master/LICENSE "Copyright © 2018 stanwood GmbH") file for more info.
