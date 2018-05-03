# StanwoodDialog

[![CI Status](https://www.bitrise.io/app/200a49178c1c4df4/status.svg?token=sfQNfpyzN4c_FAGGTefmqw&branch=master?style=flat)](https://www.bitrise.io/app/200a49178c1c4df4#/builds)
[![Swift Version](https://img.shields.io/badge/Swift-4.0.x-orange.svg)]()
[![iOS 8+](https://img.shields.io/badge/iOS-9+-EB7943.svg)]()

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Stanwood_Dialog_iOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'StanwoodDialog'
```
Also, make sure you include these 2 lines at the top of your Podfile:
```ruby
source 'git@github.com:CocoaPods/Specs.git'
source 'git@github.com:stanwood/Cocoa_Pods_Specs.git'
```

## Usage

Add `import StanwoodDialog` to your `AppDelegate` and add this call to `applicationDidBecomeAvailable`:
```
func buildRatingDialog() {
    if RatingDialog.shouldShow(onLaunch: 5) {
        let text1 = "Hi,\nich bin Hannes, der Entwicker\nvon dieser app."
        let text2 = "Kleine App-Entwicker wie wir leben von gutten Bewertungen im App-Store."
        let text3 = "Wenn Ihnen unsere App gefallt dann bewertend Sie uns doch bitte."
        let text4 = "Sternchen reichen - dauert nur 1 Minute."

        let cancel = "Schließen"
        let accept = "App bewerten"

        let faceUrlString = "https://lh5.googleusercontent.com/-_w2wo1s6SkI/AAAAAAAAAAI/AAAAAAAAhMU/s78iSxXwVZk/photo.jpg"
        let bannerUrlString = "https://d30x8mtr3hjnzo.cloudfront.net/creatives/41868f99932745608fafdd3a03072e99"
        let appID = "1316369720"

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
}
```
Normally you would be fetching each one of these parameters remotely. For instance, from Firebase RemoteConfig to do some A/B testing and/or from a service like lokalise.co to provide internationalization.

If you don't have a URL for the profile and banner images, you may upload these to Firebase Storage (go to Store section in Firebase and click on [Upload Image]):
 * the profile image should be 300x300 pixels (this will cover the 3 variations for 100x100 points)
 * the banner image should be 300x1125 pixels (this will cover the 3 variations for 100x375 points)
 
 
 ## Test
 
Using a negative value in `RatingDialog.shouldShow(onLaunch: -1)` will result in the Rating Dialog being shown everytime.

Also, while in `Debug`, the launch count doesn't need 30 minutes from the last launch to increase its count. 


## Author

Eugène Peschard, eugene.peschard@stanwood.io

## License

StanwoodCore is a private library. See the [LICENSE](https://github.com/stanwood/Stanwood_Dialog_iOS/blob/master/LICENSE "Copyright © 2018 stanwood GmbH") file for more info.
