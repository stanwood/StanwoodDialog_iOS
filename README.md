# StanwoodDialog

[![CI Status](http://img.shields.io/travis/epeschard/Stanwood_Dialog_iOS.svg?style=flat)](https://travis-ci.org/epeschard/Stanwood_Dialog_iOS)
[![Version](https://img.shields.io/cocoapods/v/Stanwood_Dialog_iOS.svg?style=flat)](http://cocoapods.org/pods/Stanwood_Dialog_iOS)
[![License](https://img.shields.io/cocoapods/l/Stanwood_Dialog_iOS.svg?style=flat)](http://cocoapods.org/pods/Stanwood_Dialog_iOS)
[![Platform](https://img.shields.io/cocoapods/p/Stanwood_Dialog_iOS.svg?style=flat)](http://cocoapods.org/pods/Stanwood_Dialog_iOS)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Stanwood_Dialog_iOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'StanwoodDialog'
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
        let bannerUrlString = "https://media.istockphoto.com/photos/plitvice-lakes-picture-id500463760?s=2048x2048"
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
Normally you would be fetching the each one of these parameters remotely. For instance from Firebase RemoteConfig to do some A/B testing and from a service like lokalise.co to provide internationalization.

## Author

epeschard, e@peschard.me

## License

Stanwood_Dialog_iOS is available under the MIT license. See the LICENSE file for more info.
