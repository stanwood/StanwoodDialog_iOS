# StanwoodDialog

[![Swift Version](https://img.shields.io/badge/Swift-4.2-orange.svg)]()
[![iOS 10+](https://img.shields.io/badge/iOS-10+-EB7943.svg)]()
[![Pod Version](https://cocoapod-badges.herokuapp.com/l/StanwoodDialog/badge.png)]()
[![CodeClimate Badge](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability)](https://codeclimate.com/github/codeclimate/codeclimate/maintainability) 
[![Build Status](https://app.bitrise.io/app/200a49178c1c4df4/status.svg?token=sfQNfpyzN4c_FAGGTefmqw&branch=master)](https://app.bitrise.io/app/200a49178c1c4df4)
[![License](https://cocoapod-badges.herokuapp.com/l/StanwoodDialog/badge.svg)](http://cocoapods.org/pods/StanwoodDialog) 
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
```swift
    if RatingDialog.shouldShow(onLaunch: 5) {
        let text1 = "Hi there,\nmy name is John Appleseed,\nthe developer of this app."
        let text2 = "Independent developers like me\nrely heavily on good ratings in the app store"
        let text3 = "so that we can continue working on apps.\nIf you like this app, I'd be thrilled\nif you left a positive rating."
        let text4 = "the stars would be enough, it will only take a few seconds."

        let cancel = "Cancel"
        let accept = "Rate the app"

        let faceUrlString = "https://lh5.googleusercontent.com/-_w2wo1s6SkI/AAAAAAAAAAI/AAAAAAAAhMU/s78iSxXwVZk/photo.jpg"
        let bannerUrlString = "https://d30x8mtr3hjnzo.cloudfront.net/creatives/41868f99932745608fafdd3a03072e99"
        let appID = "<YOUR_APPID>"

        RatingDialog.builder()
        .set(paragraph1: text1)
        .set(paragraph2: text2)
        .set(paragraph3: text3)
        .set(paragraph4: text4)
        .set(cancelText: cancel)
        .set(okText: accept)
        .set(faceUrl: faceUrlString)
        .set(bannerUrl: bannerUrlString)
        .set(tintColor: UIColor.blue)
        .buildAppStoreUrl(with: appID)
        .set(rootView: (window?.rootViewController?.view)!)
        .build()
    }
```
Ideally you would be fetching each one of these parameters remotely. For instance, from Firebase RemoteConfig to do some A/B testing and/or from a service like lokalise.co to provide internationalization.

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
