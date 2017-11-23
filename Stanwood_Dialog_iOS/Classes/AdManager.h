//
//  AdManager.h
//  ON AIR
//
//  Created by Hannes Kleist on 14/07/2010.
//  Copyright 2014 Hannes Kleist. All rights reserved.


#import <MNGAds/MNGAdsSDKFactory.h>

#import "MNGFactoryManager.h"

static NSString *const kNotificationLoadedStandardAd = @"kNotificationLoadedStandardAd";
static NSString *const kNotificationLoadedMediumRectangle = @"kNotificationLoadedMediumRectangle";
static NSString *const kNotificationLoadedNativeAd = @"kNotificationLoadedNativeAd";
static NSString *const kNotificationLoadedContentAd = @"kNotificationLoadedContentAd";
static NSString *const kNotificationLoadedFullscreenAd = @"kNotificationLoadedFullscreenAd";
static NSString *const kNotificationFinishedExitAd = @"kNotificationFinishedExitAd";


@protocol ViewControllerAdControl
- (BOOL) usesScrollingAds;
- (BOOL) allowsAds;
@end

@interface AdManager : NSObject <MNGAdsSDKFactoryDelegate>

+ (AdManager*) sharedAdManager;

@property (nonatomic, strong) MNGNAtiveObject *nativeAd;
@property (nonatomic, strong) MNGAdsSDKFactory *nativeAdFactory;
@property (nonatomic, strong) UIView *nativeAdView;
@property (nonatomic, strong) UIView *contentAd;
@property (nonatomic, strong) MNGAdsSDKFactory *contentAdFactory;
@property (nonatomic, strong) MNGAdsSDKFactory *interstitialAdFactory;
@property (nonatomic, strong) UIView *fullScreenAd;
@property (nonatomic, strong) MNGAdsSDKFactory *fullScreenAdFactory;
@property (nonatomic, strong) UIView *mediumRectangle;
@property (nonatomic, strong) MNGAdsSDKFactory *mediumRectAdFactory;

@property (nonatomic, strong) MNGFactoryManager *factoryManager;

@property BOOL interstitialShownThisSession;

@property BOOL hasLoadedInterstitial;
@property BOOL hasLoadedStandardBanner;
@property BOOL hasLoadedNativeAd;
@property BOOL hasLoadedContentAd;
@property BOOL hasLoadedFullscreenAd;
@property BOOL isLoadingNativeAd;
@property BOOL isLoadingContentAd;
@property BOOL hasLoadedMediumRectangle;

- (void) hideStandardBanner;
- (void) loadInterstitial;
- (void) loadAds;
- (void) loadContentAd;
- (void) loadStandardBanner;
- (void) loadNativeAd;
- (void) loadFullscreenAd;
- (void) loadOverlayAd;
- (void) hideNativeAd;
- (void) loadMediumRectangle;


- (MNGPreference*) preference;

- (UIView*) standardBannerContainerForTableViewCell;
- (UIView*) standardBannerContainerForBottom;
- (UIView*) contentAdContainerForTableViewCell;

- (void) closeOverlay;

@end
