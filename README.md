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

        do {
            try RatingDialog.builder()
            .set(paragraph1: text1)
            .set(paragraph2: text2)
            .set(paragraph3: text3)
            .set(paragraph4: text4)
            .set(cancelText: cancel)
            .set(okText: accept)
            .set(faceUrl: faceUrlString)
            .set(bannerUrl: bannerUrlString)
            .buildAppStoreUrl(with: appID)
            .set(rootView: (window?.rootViewController?.view)!)
            .build()
        } catch {
            print(error)
        }
    }
}
```
Normally you would be fetching each one of these parameters remotely. For instance, from Firebase RemoteConfig to do some A/B testing and/or from a service like lokalise.co to provide internationalization.

The image for the face profile should be 300 x 300 pixels and the banner image should be 300 x 1125 pixels. If you don't have a URL for these images already, you may add them to Firebase Storage.

### Add Images to Firebase Storage
Go to your projects Firebase webpage and click on the UPLOAD FILE button:
![Firebase Storage Upload File](/images/FB_Storage_Upload_File.png)
Once you have the image, select it and copy its download URL:
![Firebase Storage Image URL](/images/FB_Storage_Image_URL.png)


## Author

Eugène Peschard, eugene.peschard@stanwood.io

## License

StanwoodCore is a private library. See the [LICENSE](https://github.com/stanwood/Stanwood_Dialog_iOS/blob/master/LICENSE "Copyright © 2018 stanwood GmbH") file for more info.
