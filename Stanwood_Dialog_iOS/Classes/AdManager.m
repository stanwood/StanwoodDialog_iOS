//
//  AdManager.m
//  ON AIR
//
//  Created by Hannes Kleist on 14/07/2010.
//  Copyright 2014 Hannes Kleist. All rights reserved.
//

#import "AdManager.h"
#import "Constants.h"

#import "AppDelegate.h"
#import "AccountManager.h"
#import "InAppPurchaseManager.h"
#import "TrackingManager.h"
#import "SWSplitTestingManager.h"
#import "ConfigManager.h"
#import "Program.h"
#import "Station.h"

#import "HighlightsViewController.h"
#import "StartScreenViewController.h"
#import "ProgramDetailViewController.h"
#import "GridViewController.h"

#import "UIViewController+UIViewController_Additions.h"
#import "UIImage+Additions.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <sys/sysctl.h>
#import <INFOnlineLibrary/INFOnlineLibrary.h>
#import <AdSupport/ASIdentifierManager.h>
#import "Pods/MNGAds/MNGAds/MngAds/MNGBannerView.h"
#import "Pods/MNGAds/MNGAds/MngAds/MNGNAtiveObject.h"
#import "RateMeViewController.h"
#import "RateOverlayAd.h"

#define kContentAdFallbackRect CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)
#define kParalaxFallbackHeightMax 100.0

@interface AdManager() <MNGAdsAdapterBannerDelegate, MNGAdsAdapterNativeDelegate, MNGAdsAdapterInterstitialDelegate, MNGAdsAdapterRefreshDelegate, MNGClickDelegate>
{
    id _clickTrackingErrorObserver;
    id _standardBannerInitObserver;
    id _mediumRectangleInitObserver;
    id _nateiveAdInitObserver;
    id _contentAdInitObserver;
    id _overlayAdInitObserver;
    id _fullscreenAdInitObserver;
    id _interstitialInitObserver;
}

@property int numberOfPageViews;
@property CGSize bannerAdSize;
@property (nonatomic, strong) UIView *standardBanner;
@property (nonatomic, strong) MNGAdsSDKFactory *bannerAdFactory;
@property (nonatomic, strong) UIView * standardBannerContainer;
@property (nonatomic, strong) UIView * contentAdContainer;
@property (nonatomic, strong) UIView * overlayBannerContainer;
@property (nonatomic, strong) RateOverlayAd *overlayAd;
@property (nonatomic, strong) MNGAdsSDKFactory *overlayAdFactory;
@property (nonatomic, strong) NSDate *startdateLoadingAd;

- (AdManager*) init;

- (void) animateStandardBannerIn;
- (void) setStandardBannerFrame;

- (UIViewController<ViewControllerAdControl>*) currentViewController;
- (UIViewController*) parentViewController;

@end

@implementation AdManager
@synthesize factoryManager;

#pragma mark -
#pragma mark Singleton Instance

static AdManager *sharedAdManager = nil;
+ (AdManager*) sharedAdManager {
    if (sharedAdManager == nil) {
        sharedAdManager = [[super allocWithZone:NULL] init];
    }
	return sharedAdManager;
}
+ (id)allocWithZone:(NSZone *)zone {
	return [self sharedAdManager];
}
- (id)copyWithZone:(NSZone *)zone {
	return self;
}
- (id) init {

	self = [super init];
    if (self) {
        
        factoryManager = [[MNGFactoryManager alloc] init];
    }
	return self;
}

#pragma mark - MNGAdsSDKFactoryDelegate

- (void)MNGAdsSDKFactoryDidFinishInitializing {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMNGAdFactoryFinishedInit
                                                        object:nil];
}

#pragma mark -
#pragma mark Load Banners

- (void) loadAds {

	BOOL agofTrackingDisable = [[NSUserDefaults standardUserDefaults] boolForKey:kAgofTrackingDisabled];
	if (!agofTrackingDisable) {

		if ([self.currentViewController isKindOfClass:[StartScreenViewController class]] || [self.currentViewController isKindOfClass:[HighlightsViewController class]]) {
			[[IOLSession defaultSession] logEventWithType:IOLEventTypeView state:IOLViewAppeared category:@"homepage" comment:nil];
		} else {
			[[IOLSession defaultSession] logEventWithType:IOLEventTypeView state:IOLViewAppeared category:@"content" comment:nil];
		}
	}

	//HIDE ADS FOR BLIND PEOPLE
	if (UIAccessibilityIsVoiceOverRunning())
		return;

	_numberOfPageViews++;

	//SHOW OVERLAYS IN ALL VIEW
//    [self loadOverlayAd];
    [self buildOverlayAd];
//    [self showRateMeAd];
    
    [self hideStandardBanner];

	//ONLY IN CERTAIN VIEWS
	if (![self shouldAdBeDisplayed]) {

		//[self hideStandardBanner];
		[self hideMediumRectangle];
		return;
	}

	if (self.currentViewController.usesScrollingAds) {

        if (isiPad) {
            [self loadMediumRectangle];
        } else {
            //if ([self hasLoadedContentAd]) {
            //}
            [self loadContentAd];
        }
	} else {
        if (![self.currentViewController isKindOfClass:[ProgramDetailViewController class]]) {
            [self loadStandardBanner];
        } else {
            [self loadMediumRectangle];
        }
	}

	_startdateLoadingAd = [NSDate date];
    
}

- (void) reloadStandardBannerWithTimeout {

	int adTimeIntervalBetweenBanners = [[[ConfigManager sharedConfigManager] numberForKey:kKeyAdTimeIntervalBetweenBanners] intValue];


	if (adTimeIntervalBetweenBanners > 0) {
		[self performSelector:@selector(loadStandardBanner) withObject:nil afterDelay:adTimeIntervalBetweenBanners];
	}
}

- (void) reloadMediumRectangleWithTimeout {

	int adTimeIntervalBetweenBanners = [[[ConfigManager sharedConfigManager] numberForKey:kKeyAdTimeIntervalBetweenBanners] intValue];

	if (adTimeIntervalBetweenBanners > 0) {
		[self performSelector:@selector(loadMediumRectangle) withObject:nil afterDelay:adTimeIntervalBetweenBanners];
	}
}

- (void) loadStandardBanner {

#if (TARGET_IPHONE_SIMULATOR)
#else
	CLS_LOG(@"");
#endif
    if (_standardBannerInitObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_standardBannerInitObserver];
        _standardBannerInitObserver = nil;
    }
    //If MNGAdsFactory isn't initialised, try again when it is.
    __weak __typeof__(self) weakSelf = self;
    if ([MNGFactoryManager isFactoryInitialisedForAppID:MNGAppID]) {

	//Stop all other reload timers
	// Otherwise the reload will be killed at every PI

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
    CGRect frame = isiPad ? kMNGAdSizeLeaderboard : kMNGAdSizeBanner;

	if (self.bannerAdFactory == nil) {
        self.bannerAdFactory = [[MNGAdsSDKFactory alloc] init];
		//CREATE AD
        NSString* adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdBanner320x50];//ez @"/2472080/startbanner"
        if (isiPad) adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdBanner728x90];//ez@"/1406392/contentleaderboard"
//		self.standardBanner = [[MPAdView alloc] initWithAdUnitId:adUnitID size:size];
//		[self.standardBanner stopAutomaticallyRefreshingContents];
		self.bannerAdFactory.clickDelegate = self;
        self.bannerAdFactory.viewController = self.parentViewController;
        self.bannerAdFactory.bannerDelegate = self;
        self.bannerAdFactory.isrefreshFactory = YES;
        self.bannerAdFactory.refreshDelegate = self;
        self.bannerAdFactory.placementId = adUnitID;

        [self.bannerAdFactory loadBannerInFrame:frame
                                withPreferences:[self preference]];
            [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Banner" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
	} else {

        //Pause on a backend thread while adsFactory is busy
        if (self.bannerAdFactory.isBusy) {
            __weak __typeof__(self.bannerAdFactory) weakAdsFactory = self.bannerAdFactory;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                //Pause on a backend thread while adsFactory is busy
                while (weakAdsFactory.isBusy) {
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf loadStandardBanner];
                });
            });
            return;
        }
		//if (self.hasLoadedStandardBanner) {

			//[self animateStandardBannerIn];
			//[self addScreenshotToBackgroundOfStandardBanner];
            [self.bannerAdFactory loadBannerInFrame:frame
                                    withPreferences:[self preference]];
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Banner" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];

		//}
	}
    } else {
        _standardBannerInitObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationMNGAdFactoryFinishedInit
                                                                                        object:nil
                                                                                         queue:nil
                                                                                    usingBlock:^(NSNotification * _Nonnull note) {
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            [weakSelf loadStandardBanner];
                                                                                        });
                                                                                    }];
        return;
    }
}

- (void) loadMediumRectangle {
    if (![self shouldAdBeDisplayed]) {
        return;
    }
#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"");
#endif
    if (_mediumRectangleInitObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_mediumRectangleInitObserver];
        _mediumRectangleInitObserver = nil;
    }
    //If MNGAdsFactory isn't initialised, try again when it is.
    __weak __typeof__(self) weakSelf = self;
    if ([MNGFactoryManager isFactoryInitialisedForAppID:MNGAppID]) {
        
        //Stop all other reload timers
        // Otherwise the reload will be killed at every PI
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        CGRect frame = kMNGAdSizeMediumRectangle;
        
        if (self.mediumRectAdFactory == nil) {
            self.mediumRectAdFactory = [[MNGAdsSDKFactory alloc] init];
            //CREATE AD
            NSString * adUnitID =  [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdMediumRectangle300x250];//ez@"/1406392/mrt"
            if (isiPad) {
                adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdiPadMediumRectangle300x250];
            }
            //		self.standardBanner = [[MPAdView alloc] initWithAdUnitId:adUnitID size:size];
            //		[self.standardBanner stopAutomaticallyRefreshingContents];
            self.mediumRectAdFactory.clickDelegate = self;
            self.mediumRectAdFactory.viewController = self.parentViewController;
            self.mediumRectAdFactory.bannerDelegate = self;
            self.mediumRectAdFactory.isrefreshFactory = YES;
            self.mediumRectAdFactory.refreshDelegate = self;
            self.mediumRectAdFactory.placementId = adUnitID;
            
            [self.mediumRectAdFactory loadBannerInFrame:frame
                                        withPreferences:[self preference]];
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MediumRectangle" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
            
        } else {
            
            //Pause on a backend thread while adsFactory is busy
            if (self.mediumRectAdFactory.isBusy) {
                __weak __typeof__(self.mediumRectAdFactory) weakAdsFactory = self.mediumRectAdFactory;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    //Pause on a backend thread while adsFactory is busy
                    while (weakAdsFactory.isBusy) {
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf loadMediumRectangle];
                    });
                });
                return;
            }
            
                [self.mediumRectAdFactory loadBannerInFrame:frame
                                            withPreferences:[self preference]];
                    [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MediumRectangle" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
        }
    } else {
        _mediumRectangleInitObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationMNGAdFactoryFinishedInit
                                                                                        object:nil
                                                                                         queue:nil
                                                                                    usingBlock:^(NSNotification * _Nonnull note) {
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            [weakSelf loadMediumRectangle];
                                                                                        });
                                                                                    }];
        return;
    }
}

- (void) loadNativeAd {

    
#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"");
#endif
    if (_nateiveAdInitObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_nateiveAdInitObserver];
        _nateiveAdInitObserver = nil;
    }
    
    if (![self shouldAdBeDisplayed]) {
        
        [self hideMediumRectangle];
        return;
    }
    
    //If MNGAdsFactory isn't initialised, try again when it is.
    __weak __typeof__(self) weakSelf = self;
    if ([MNGFactoryManager isFactoryInitialisedForAppID:MNGAppID]) {
        
        //Stop all other reload timers
        // Otherwise the reload will be killed at every PI
                
        CGSize size;
        if (isiPad) {
            //CLS_LOG(@"isLandscape: %d", orientationIsLandscape);
            size = (orientationIsLandscape) ? CGSizeMake(1024, 300) : CGSizeMake(768, 300);
        } else {
            size = CGSizeMake(160, 160);
        }
        
        if (self.nativeAdFactory == nil) {
            self.nativeAdFactory = [[MNGAdsSDKFactory alloc] init];
            //CREATE AD
            NSString * adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdNative160x160];//ez@"/2472080/special"
            if (isiPad) {
                if (orientationIsLandscape) {
                    adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdNative1024x300];//ez@"/1406392/spclandscape"
                } else {
                    adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdNative768x300];//ez@"/1406392/spcportrait"
                }
            }
            //		self.standardBanner = [[MPAdView alloc] initWithAdUnitId:adUnitID size:size];
            //		[self.standardBanner stopAutomaticallyRefreshingContents];
            self.nativeAdFactory.clickDelegate = self;
            self.nativeAdFactory.viewController = self.parentViewController;
            self.nativeAdFactory.nativeDelegate = self;
            self.nativeAdFactory.isrefreshFactory = YES;
            self.nativeAdFactory.refreshDelegate = self;
            self.nativeAdFactory.placementId = adUnitID;
            
            [self.nativeAdFactory loadNativeWithPreferences:[self preference]];
                self.isLoadingNativeAd = YES;
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"NativeAd" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
        } else {
            
            //Pause on a backend thread while adsFactory is busy
            if (self.nativeAdFactory.isBusy) {
                __weak __typeof__(self.nativeAdFactory) weakAdsFactory = self.nativeAdFactory;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    //Pause on a backend thread while adsFactory is busy
                    while (weakAdsFactory.isBusy) {
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf loadNativeAd];
                    });
                });
                return;
            }
            
            [self.nativeAdFactory loadNativeWithPreferences:[self preference]];
            self.isLoadingNativeAd = YES;
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"NativeAd" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
        }
    } else {
        _nateiveAdInitObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationMNGAdFactoryFinishedInit
                                                                                         object:nil
                                                                                          queue:nil
                                                                                     usingBlock:^(NSNotification * _Nonnull note) {
                                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                                             [weakSelf loadNativeAd];
                                                                                         });
                                                                                     }];
        return;
    }
}

- (void) loadContentAd {
#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"");
#endif
    if (![self shouldAdBeDisplayed]) {
        
        // [self hideContentAd];
        //[self hideMediumRectangle];
        return;
    }
    
    if (_contentAdInitObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_contentAdInitObserver];
        _contentAdInitObserver = nil;
    }
    //If MNGAdsFactory isn't initialised, try again when it is.
    __weak __typeof__(self) weakSelf = self;
    if ([MNGFactoryManager isFactoryInitialisedForAppID:MNGAppID]) {
        
        //Stop all other reload timers
        // Otherwise the reload will be killed at every PI
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        CGRect frame = kMNGAdSizeDynamicBanner;
        frame.size.width = [[UIScreen mainScreen] bounds].size.width;
        frame.size.height = 100;
        
        if (self.contentAdFactory == nil) {
            self.contentAdFactory = [[MNGAdsSDKFactory alloc] init];
            //CREATE AD
            NSString * adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdContent320xDynamic];//ez@"/2472080/infeed"
            //		self.standardBanner = [[MPAdView alloc] initWithAdUnitId:adUnitID size:size];
            //		[self.standardBanner stopAutomaticallyRefreshingContents];
            self.contentAdFactory.clickDelegate = self;
            self.contentAdFactory.viewController = self.parentViewController;
            self.contentAdFactory.bannerDelegate = self;
            self.contentAdFactory.isrefreshFactory = YES;
            self.contentAdFactory.refreshDelegate = self;
            self.contentAdFactory.placementId = adUnitID;
            
            [self.contentAdFactory loadBannerInFrame:frame
                                     withPreferences:[self preference]];
                self.isLoadingContentAd = YES;
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"ContentAd" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
        } else {
            NSString * adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdContent320xDynamic];//ez@"/2472080/infeed"
            self.contentAdFactory.placementId = adUnitID;
            //Pause on a backend thread while adsFactory is busy
            if (self.contentAdFactory.isBusy) {
                __weak __typeof__(self.contentAdFactory) weakAdsFactory = self.contentAdFactory;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    //Pause on a backend thread while adsFactory is busy
                    while (weakAdsFactory.isBusy) {
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf loadContentAd];
                    });
                });
                return;
            }
            
            [self.contentAdFactory loadBannerInFrame:frame
                                     withPreferences:[self preference]];
                self.isLoadingContentAd = YES;
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"ContentAd" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
            }
    } else {
        _contentAdInitObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationMNGAdFactoryFinishedInit
                                                                                   object:nil
                                                                                    queue:nil
                                                                               usingBlock:^(NSNotification * _Nonnull note) {
                                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                                             [weakSelf loadContentAd];
                                                                                         });
                                                                                     }];
        return;
    }
}

- (NSString *) createOverlayContent {
    NSString * overlayContent = [[ConfigManager sharedConfigManager] stringForKey:kKeyOverlay300x600iPhone];
    if (isiPad)
        overlayContent = [[ConfigManager sharedConfigManager] stringForKey:kKeyOverlay300x600iPad];
    return overlayContent;
}

- (void) showRateMeAd {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfAppStartsKey] == 5) {
        RateMeViewController *rateMeViewController = [[RateMeViewController alloc] initWithNibName:@"RateMeViewController" bundle:nil];
        if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *) self.parentViewController;
            [navController pushViewController:rateMeViewController animated:YES];
        }
        [self performSelector:@selector(closeRateMeAd) withObject:nil afterDelay:30];
        
        [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"NewRate" withLabel:nil];
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"NewRate" action:@"DidLoad" label:NSStringFromClass([[self currentViewController] class]) value:0];
    }
}

- (void) closeRateMeAd {
    // TODO: check how to cancel the perforRequest
//    [SKStoreReviewController cancelPreviousPerformRequestsWithTarget:<#(nonnull id)#> selector:<#(nonnull SEL)#> object:<#(nullable id)#>];
//    [SKStoreReviewController cancelPreviousPerformRequestsWithTarget:<#(nonnull id)#>]
    
    UINavigationController *navController = (UINavigationController *) self.parentViewController;
    [navController popViewControllerAnimated:YES];
}

- (void) buildOverlayAd {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfAppStartsKey] == 5) {
        self.overlayAd = [[[NSBundle mainBundle] loadNibNamed:@"RateOverlayAd" owner:self options:nil] lastObject];
        self.overlayAd.textLabel.text = [[ConfigManager sharedConfigManager] stringForKey:kKeyRateMeDialog];

        //ADD BLACK SCREEN
        self.overlayBannerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height)];
        self.overlayBannerContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];

        CGRect frame = self.overlayAd.frame;
        frame.origin.x = (self.overlayBannerContainer.frame.size.width - frame.size.width) / 2;
        frame.origin.y = (self.overlayBannerContainer.frame.size.height - frame.size.height) / 2;
        self.overlayAd.frame = frame;
        
        [self.overlayBannerContainer addSubview:self.overlayAd];
        self.overlayBannerContainer.alpha = 0;
        self.overlayAd.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        [self.parentViewController.view addSubview:self.overlayBannerContainer];

        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.overlayBannerContainer.alpha = 1;
            self.overlayAd.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:nil];
        
        [self performSelector:@selector(closeOverlay) withObject:nil afterDelay:30];
        
        [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Overlay" withLabel:nil];
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Overlay" action:@"DidLoad" label:NSStringFromClass([[self currentViewController] class]) value:0];
    }
}

- (void) loadOverlayAd {
    
#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"");
#endif
    if (!self.overlayAd) {
        NSString * overlayContent = self.createOverlayContent;
        if (overlayContent && overlayContent.length > 0) {
            [[NSNotificationCenter defaultCenter] removeObserver:_overlayAdInitObserver];
            _overlayAdInitObserver = nil;
            if ([[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfAppStartsKey] == 1 || [overlayContent containsString:@"discontinuing"]) {
                self.overlayAd = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 450)];
                [((UIWebView *)self.overlayAd) loadHTMLString:overlayContent
                                                      baseURL:nil];
                self.overlayAd.backgroundColor = [UIColor clearColor];
                self.overlayAd.layer.cornerRadius = 6.0;
                self.overlayAd.layer.masksToBounds = YES;
                //ADD BLACK SCREEN
                self.overlayBannerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height)];
                self.overlayBannerContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
//                UIButton * button = [[UIButton alloc] initWithFrame:self.overlayBannerContainer.frame];
//
//                [button addTarget:self action:@selector(closeOverlay) forControlEvents:UIControlEventTouchUpInside];
//                [self.overlayBannerContainer addSubview:button];
                CGRect frame = self.overlayAd.frame;
                frame.origin.x = (self.overlayBannerContainer.frame.size.width - frame.size.width) / 2;
                frame.origin.y = (self.overlayBannerContainer.frame.size.height - frame.size.height) / 2;
                self.overlayAd.frame = frame;
                [self.overlayBannerContainer addSubview:self.overlayAd];
                self.overlayBannerContainer.alpha = 0;
                self.overlayAd.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                [self.parentViewController.view addSubview:self.overlayBannerContainer];

                [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.overlayBannerContainer.alpha = 1;
                    self.overlayAd.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                    [((UIWebView *)self.overlayAd).scrollView setContentInset:UIEdgeInsetsMake(-8, -8, -8, 0)];

                } completion:nil];

                [self performSelector:@selector(closeOverlay) withObject:nil afterDelay:30];
                
                [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Overlay" withLabel:nil];
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Overlay" action:@"DidLoad" label:NSStringFromClass([[self currentViewController] class]) value:0];
            }
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:_overlayAdInitObserver];
            _overlayAdInitObserver = nil;
            _overlayAdInitObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationRemoteConfigDidRefresh
                                                                                       object:nil
                                                                                        queue:nil
                                                                                   usingBlock:^(NSNotification * _Nonnull note) {
                                                                                       DISPATCH_ON_MAIN(^{
                                                                                           [self loadOverlayAd];
                                                                                       });
                                                                                   }];
        }
    }
}

- (void) loadFullscreenAd {

#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"");
#endif
    if (_fullscreenAdInitObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_fullscreenAdInitObserver];
        _fullscreenAdInitObserver = nil;
    }
    [self hideFullscreenBanner];
    
    //ONLY IN CERTAIN VIEWS
    if (![self shouldAdBeDisplayed]) {
        
        [self hideStandardBanner];
        [self hideMediumRectangle];
        
    }
    //If MNGAdsFactory isn't initialised, try again when it is.
    __weak __typeof__(self) weakSelf = self;
    if ([MNGFactoryManager isFactoryInitialisedForAppID:MNGAppID]) {
        
        CGRect frame = CGRectMake(0, 0, 0, 0);
        CGSize size = CGSizeMake(320, 480);
        if (isiPad && orientationIsLandscape) size = CGSizeMake(1024, 768);
        if (isiPad && !orientationIsLandscape) size = CGSizeMake(768, 1024);
        
        frame.size = size;
        
        if (self.fullScreenAdFactory == nil) {
            self.fullScreenAdFactory = [[MNGAdsSDKFactory alloc] init];
            //CREATE AD
            NSString * adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdSwipeable320x480];//ez@"/2472080/swipe"
            if (isiPad && orientationIsLandscape) adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdSwipeable1024x768];//ez@"/1406392/swipelandscape"
            if (isiPad && !orientationIsLandscape) adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdSwipeable768x1024];//ez@"/1406392/swipeportrait"

            //		self.standardBanner = [[MPAdView alloc] initWithAdUnitId:adUnitID size:size];
            //		[self.standardBanner stopAutomaticallyRefreshingContents];
            self.fullScreenAdFactory.clickDelegate = self;
            self.fullScreenAdFactory.viewController = self.parentViewController;
            self.fullScreenAdFactory.bannerDelegate = self;
            self.fullScreenAdFactory.isrefreshFactory = YES;
            self.fullScreenAdFactory.refreshDelegate = self;
            self.fullScreenAdFactory.placementId = adUnitID;
            
            [self.fullScreenAdFactory loadBannerInFrame:frame
                                        withPreferences:[self preference]];
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Fullscreen" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
           } else {
            
            //Pause on a backend thread while adsFactory is busy
            if (self.fullScreenAdFactory.isBusy) {
                __weak __typeof__(self.fullScreenAdFactory) weakAdsFactory = self.fullScreenAdFactory;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    //Pause on a backend thread while adsFactory is busy
                    while (weakAdsFactory.isBusy) {
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf loadFullscreenAd];
                    });
                });
                return;
            }
            
            [self.fullScreenAdFactory loadBannerInFrame:frame
                                        withPreferences:[self preference]];
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Fullscreen" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
           }
    } else {
        _fullscreenAdInitObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationMNGAdFactoryFinishedInit
                                                                                   object:nil
                                                                                    queue:nil
                                                                               usingBlock:^(NSNotification * _Nonnull note) {
                                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                                       [weakSelf loadFullscreenAd];
                                                                                   });
                                                                               }];
        return;
    }
}

- (void) loadInterstitial {

#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"");
#endif
    if (_interstitialInitObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_interstitialInitObserver];
        _interstitialInitObserver = nil;
    }
    
    //IF LOADED >> SHOW
    if (self.interstitialAdFactory != nil && [self.interstitialAdFactory isInterstitialReady]) {
        [self showInterstitial];
        return;
    }
    
    if (![self interstitialShouldShow]) {
        //#warning Remove this;
       return;
    }

    //If MNGAdsFactory isn't initialised, try again when it is.
    __weak __typeof__(self) weakSelf = self;
    if ([MNGFactoryManager isFactoryInitialisedForAppID:MNGAppID]) {
        
        CGRect frame = CGRectMake(0, 0, 0, 0);
        CGSize size = CGSizeMake(320, 480);
        if (isiPad && orientationIsLandscape) size = CGSizeMake(1024, 768);
        if (isiPad && !orientationIsLandscape) size = CGSizeMake(768, 1024);
        
        frame.size = size;
        
        if (self.interstitialAdFactory == nil) {
            self.interstitialAdFactory = [[MNGAdsSDKFactory alloc] init];
            //CREATE AD
            NSString * adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdInterstitial320x480];//ez@"/2472080/interstitial"
            if (isiPad && orientationIsLandscape) adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdInterstitial1024x768];//ez@"/1406392/interstitiallandscape"
            if (isiPad && !orientationIsLandscape) adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdInterstitial768x1024];//ez@"/1406392/interstitialportrait"
            
            //		self.standardBanner = [[MPAdView alloc] initWithAdUnitId:adUnitID size:size];
            //		[self.standardBanner stopAutomaticallyRefreshingContents];
            self.interstitialAdFactory.clickDelegate = self;
            self.interstitialAdFactory.interstitialDelegate = self;
            self.interstitialAdFactory.isrefreshFactory = YES;
            self.interstitialAdFactory.refreshDelegate = self;
            self.interstitialAdFactory.placementId = adUnitID;
            self.interstitialAdFactory.viewController = self.parentViewController;

            [self.interstitialAdFactory loadInterstitialWithPreferences:[self preference]
                                                          autoDisplayed:YES];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastInterstitialRequested];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Interstitial" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
            } else {
            
            //Pause on a backend thread while adsFactory is busy
            if (self.interstitialAdFactory.isBusy) {
                __weak __typeof__(self.interstitialAdFactory) weakAdsFactory = self.interstitialAdFactory;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    //Pause on a backend thread while adsFactory is busy
                    while (weakAdsFactory.isBusy) {
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf loadInterstitial];
                    });
                });
                return;
            }
            
            [self.interstitialAdFactory loadInterstitialWithPreferences:[self preference]
                                                          autoDisplayed:YES];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastInterstitialRequested];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Interstitial" action:@"Request" label:NSStringFromClass([[self currentViewController] class]) value:0];
            }
    } else {
        _interstitialInitObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationMNGAdFactoryFinishedInit
                                                                                      object:nil
                                                                                       queue:nil
                                                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                                          [weakSelf loadInterstitial];
                                                                                      });
                                                                                  }];
        return;
    }
}

-(BOOL)interstitialShouldShow {
    //#warning Remove this
    //[[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:-(60*60*60)] forKey:kLastInterstitialRequested];
    //[[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:-(60*60*60)] forKey:kLastInterstitialShown];
    
    if (![self shouldAdBeDisplayed]) {
        return NO;
    }
    //ONLY LOAD X DAYS AFTER LAST INTERSTITIAL HAS BEEN REQUESTED
    NSDate * lastInterstitialRequested = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:kLastInterstitialRequested];
    int requestInterval = [[[ConfigManager sharedConfigManager] numberForKey:kKeyAdTimeIntervalBetweenInterstitialRequests] intValue];
    NSDate * lastInterstitialShown = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:kLastInterstitialShown];
    int impressionInterval = [[[ConfigManager sharedConfigManager] numberForKey:kKeyAdTimeIntervalBetweenInterstitialImpressions] intValue];
    //#warning Remove this
    //interval = 30;
    NSDate * nextInterstitialShallBeRequested = lastInterstitialShown ? (([[NSDate dateWithTimeInterval:impressionInterval sinceDate:lastInterstitialShown] compare:[NSDate dateWithTimeInterval:requestInterval sinceDate:lastInterstitialRequested]] == NSOrderedDescending) ? [NSDate dateWithTimeInterval:impressionInterval sinceDate:lastInterstitialShown] : [NSDate dateWithTimeInterval:requestInterval sinceDate:lastInterstitialRequested]) : [NSDate dateWithTimeInterval:requestInterval sinceDate:lastInterstitialRequested];
    NSDate * now = [NSDate date];
    if ([nextInterstitialShallBeRequested compare:now] == NSOrderedDescending) {
        return NO;
    }
    
    return YES;
}

- (MNGPreference*) preference {

    MNGPreference *preference = [[MNGPreference alloc] init];
    
    if ([[AccountManager sharedAccountManager].user.gender intValue] == 1) {
        preference.gender = MNGGenderMale;
    }
    if ([[AccountManager sharedAccountManager].user.gender intValue] == -1) {
        preference.gender = MNGGenderFemale;
    }
    preference.language = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2] ;
	NSString * className = [[[NSStringFromClass(self.currentViewController.class) stringByReplacingOccurrencesOfString:@"ViewController" withString:@""] stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] stringByReplacingOccurrencesOfString:@"iPad" withString:@""];
	NSString * numberOfAppStarts = [NSString stringWithFormat:@"%i", (int)[[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfAppStartsKey]];
	NSString * validDaysLeftInSubscription = [NSString stringWithFormat:@"%d", [[InAppPurchaseManager sharedInAppPurchaseManager] validDaysLeftInSubscription]];
	NSString * userStatus = [AccountManager sharedAccountManager].user.status;
	if ([InAppPurchaseManager sharedInAppPurchaseManager].purchaseStatus == kProductStatusBought) {
		userStatus = @"pro";
	}
	NSString * numberOfAdsClicked = [NSString stringWithFormat:@"%d", (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfAdsClicked"]];
	NSNumber * provider = [AccountManager sharedAccountManager].user.provider;
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [[NSString stringWithCString:machine encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"," withString:@"."];
	free(machine);

	NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];

	NSString * test = @"";

#if (TARGET_IPHONE_SIMULATOR)
	test = @",test:1";
#else
#endif
    NSString * keywords = [NSString stringWithFormat:@"m_view=%@,m_number_of_app_starts=%@,m_valid_days_left_in_subscription=%@,m_number_of_ads_clicked=%@,m_provider=%ld,m_version=%@,m_device=%@%@", className, numberOfAppStarts, validDaysLeftInSubscription, numberOfAdsClicked, (long)[provider integerValue], version, platform, test];

    if ([[self currentViewController] isKindOfClass:[ProgramDetailViewController class]]) {
        Program *program = [((ProgramDetailViewController *)[self currentViewController]) program];
        
        if (program) {
            NSString *programTitle = program.title;
            if (programTitle && programTitle.length > 0) {
                keywords = [keywords stringByAppendingFormat:@",m_program_title=%@", programTitle];
            }
            NSString *programGenre = program.genre;
            if (programGenre && programGenre.length > 0) {
                keywords = [keywords stringByAppendingFormat:@",m_genre=%@", programGenre];
            }
            NSString *stationTitle = program.station ? program.station.title : nil;
            if (stationTitle && stationTitle.length > 0) {
                keywords = [keywords stringByAppendingFormat:@",m_station_title=%@", stationTitle];
            }
        }
    }
    
    preference.keyWord = keywords;
	return preference;
}


#pragma mark - Show ads

- (void) showInterstitial {

#if (TARGET_IPHONE_SIMULATOR)
#else
	CLS_LOG(@"");
#endif

    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        CLS_LOG(@"showInterstitial cancelled due to applicationState %ld", (long)[[UIApplication sharedApplication] applicationState]);
        return;
    }
    
	//DO NOT SHOW IN SETTINGS
	if (![self shouldAdBeDisplayed])
		return;

//    NSInteger minNumPageViews = [[[SWSplitTestingManager sharedSplitTestingManager] testValueForKey:kTestKeyMinPageViews defaultValue:@3] integerValue];
//	if (_numberOfPageViews < minNumPageViews)
//		return;
//
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastInterstitialShown];
	[[NSUserDefaults standardUserDefaults] synchronize];
    _interstitialShownThisSession = YES;
	self.interstitialAdFactory.viewController = self.parentViewController;
    if ([self.interstitialAdFactory isInterstitialReady]) {
        [self.interstitialAdFactory displayInterstitial];
    }
}

-  (void) hideStandardBanner {

	//Stop all other reload timers
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	if (self.standardBannerContainer != nil) {
        [UIView animateWithDuration:0.25 animations:^{
            
            CGRect frame2 = self.standardBannerContainer.frame;
            frame2.origin.y = frame2.origin.y+frame2.size.height;
            self.standardBannerContainer.frame = frame2;
        } completion:^(BOOL finished) {
            [self.standardBannerContainer removeFromSuperview];
            self.standardBannerContainer = nil;
            self.hasLoadedStandardBanner = NO;
        }];
	}
    if (self.standardBanner != nil) {
        //        if ([self.standardBanner respondsToSelector:@selector(delegate)]) {
        //            self.standardBanner.delegate = nil;
        //        }
        
        self.standardBanner = nil;
        self.hasLoadedStandardBanner = NO;
    }
    
    if ([self.currentViewController isKindOfClass:[GridViewController class]]) {
        GridViewController *gridVC = (GridViewController *)self.currentViewController;
        UIEdgeInsets edgeInsets = ((UIScrollView *)gridVC.gridScrollView).contentInset;
        edgeInsets.bottom = 0;
        [(UIScrollView *)gridVC.gridScrollView setContentInset:edgeInsets];
    }
}

- (void) hideMediumRectangle {

	//Stop all other reload timers
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	if (self.mediumRectangle != nil) {
//        if ([self.mediumRectangle respondsToSelector:@selector(delegate)]) {
//            self.mediumRectangle.delegate = nil;
//        }

		[self.mediumRectangle removeFromSuperview];
		self.mediumRectangle = nil;

		[AdManager sharedAdManager].hasLoadedMediumRectangle = NO;
	}
}

- (void) hideNativeAd {

	if (self.nativeAdView != nil) {
//        if ([self.nativeAd respondsToSelector:@selector(delegate)]) {
//            self.nativeAd.delegate = nil;
//        }
		[self.nativeAdView removeFromSuperview];
		self.nativeAdView = nil;
		[AdManager sharedAdManager].hasLoadedNativeAd = NO;
	}
}

- (void) hideContentAd {
    
    if (self.contentAd != nil) {
//        if ([self.contentAd respondsToSelector:@selector(delegate)]) {
//            self.contentAd.delegate = nil;
//        }
        [self.contentAd removeFromSuperview];
        self.contentAd = nil;
        [AdManager sharedAdManager].hasLoadedContentAd = NO;
    }
}

- (void) hideFullscreenBanner {

	if (self.fullScreenAd != nil) {
//        if ([self.fullScreenAd respondsToSelector:@selector(delegate)]) {
//            self.fullScreenAd.delegate = nil;
//        }
		[self.fullScreenAd removeFromSuperview];
		self.fullScreenAd = nil;
	}
}

- (void) closeOverlay {
    
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.overlayBannerContainer.alpha = 0;
        self.overlayAd.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    } completion:^(BOOL finished) {
        [self.overlayBannerContainer removeFromSuperview];
    }];
}


- (BOOL) shouldAdBeDisplayed {

	//DO NOT SHOW ON FIRST 10 STARTS
//#warning remove this - should be 10
	int minNumberOfAppStartsForAds = 10;
//#warning remove this
//    return YES;
	if ([InAppPurchaseManager sharedInAppPurchaseManager].subscriptionExists)
		return NO;

	int numberOfAppStarts = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfAppStarts"];
	if (numberOfAppStarts < minNumberOfAppStartsForAds) {
        //#warning Remove this
		return NO;
	}

	//DO NOT SHOW WHEN MODAL VIEWS ARE UP
	if (AppDelegate.navigationController.topViewController.presentingViewController != nil || [AppDelegate.navigationController.topViewController.presentingViewController isKindOfClass:[UINavigationController class]]) {
		return NO;
	}
	if (AppDelegate.tabBarController.selectedViewController.presentingViewController != nil  || [AppDelegate.tabBarController.selectedViewController.presentingViewController isKindOfClass:[UINavigationController class]]) {
		return NO;
	}

	return self.currentViewController.allowsAds;
}

- (UIViewController*) parentViewController {

	//PARENT
	if (isiPad) {
		return AppDelegate.tabBarController.selectedViewController;
	} else {
		return AppDelegate.navigationController;
	}
}

- (UIViewController*) currentViewController {

	if (isiPad) {
		if ([AppDelegate.tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
			UINavigationController * navigationController = (UINavigationController*) AppDelegate.tabBarController.selectedViewController;
			return navigationController.topViewController;
		}
	}
	return AppDelegate.navigationController.topViewController;
}

#pragma mark -
#pragma mark MNG Delegate

-(void)adsAdapterAdWasClicked:(MNGAdsAdapter *)adsAdapter {
#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"%@", adsAdapter);
#endif
    
    if (adsAdapter == self.bannerAdFactory) {
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Banner" action:@"adsAdapterAdWasClicked" label:NSStringFromClass([[self currentViewController] class]) value:0];
    }
    
    if (adsAdapter == self.mediumRectAdFactory) {
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MediumRectangle" action:@"adsAdapterAdWasClicked" label:NSStringFromClass([[self currentViewController] class]) value:0];
    }
    
    if (adsAdapter == self.nativeAdFactory) {
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"NativeAd" action:@"adsAdapterAdWasClicked" label:NSStringFromClass([[self currentViewController] class]) value:0];
    }
    
    if (adsAdapter == self.contentAdFactory) {
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"ContentAd" action:@"adsAdapterAdWasClicked" label:NSStringFromClass([[self currentViewController] class]) value:0];
    }
    
    if (adsAdapter == self.interstitialAdFactory) {
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"InterstitialAd" action:@"adsAdapterAdWasClicked" label:NSStringFromClass([[self currentViewController] class]) value:0];
    }
    
    if (adsAdapter == self.fullScreenAdFactory) {
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"FullScreenAd" action:@"adsAdapterAdWasClicked" label:NSStringFromClass([[self currentViewController] class]) value:0];
    }
    
    
    int incrementUserClickedOnAd = [self incrementUserClickedOnAd];
}

#pragma mark -
#pragma mark MNG Banner Delegate

-(void)adsAdapter:(MNGAdsAdapter *)adsAdapter bannerDidLoad:(UIView *)adView preferredHeight:(CGFloat)preferredHeight {
    adsAdapter.clickDelegate = self;
    if (adsAdapter == self.bannerAdFactory) {
    self.standardBanner = adView;
    self.standardBanner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CGRect frame = isiPad ? kMNGAdSizeLeaderboard : kMNGAdSizeBanner;
    frame.size.height = preferredHeight;
    self.standardBanner.frame = frame;
        if (self.standardBannerContainer) {
            [self.standardBannerContainer removeFromSuperview];
            self.standardBannerContainer = nil;
        }
    self.standardBannerContainer = [[UIView alloc] initWithFrame:frame];
    self.standardBannerContainer.backgroundColor = [UIColor whiteColor];
    self.standardBannerContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.standardBanner.frame = frame;
    [self.standardBannerContainer addSubview:self.standardBanner];
    [self setStandardBannerFrame];
    
        self.hasLoadedStandardBanner = YES;
        
        [self reloadStandardBannerWithTimeout];
        
        //BOTTOM ALIGN CHILDREN AND REPORT TYPE
        for (UIView * view in adView.subviews) {
            
            //ALIGN SIZE OF PARENT
            CGRect frame = adView.frame;
            frame.size.height = view.frame.size.height;
            frame.size.width = view.frame.size.width;
            adView.frame = frame;
            
            NSString * className = NSStringFromClass([view class]);
            
#if (TARGET_IPHONE_SIMULATOR)
#else
            CLS_LOG(@"%@ %@ %@", className, view, self.bannerAdFactory.placementId);
#endif
            if (_startdateLoadingAd && className) {
                [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Banner" withLabel:className];
            }
        }
        
        //ONLY SHOW BANNER IF WE ARE SURE WE HAVE NO NATIVE AD LOADING
        if ((self.isLoadingNativeAd == NO && self.hasLoadedNativeAd == NO) || ![self.currentViewController isKindOfClass:[HighlightsViewController class]]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedStandardAd object:nil];
            [self animateStandardBannerIn];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 250 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self addBackgroundColorToAdBackground];
            });
        }
        
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Banner" action:@"DidLoad" label:NSStringFromClass([[self currentViewController] class]) value:0];
    } else if (adsAdapter == self.mediumRectAdFactory) {
        self.mediumRectangle = adView;
        self.hasLoadedMediumRectangle = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedMediumRectangle object:nil];
        
#if (TARGET_IPHONE_SIMULATOR)
#else
        CLS_LOG(@"adViewDidReceiveAd MediumRectangle Ad %@", self.mediumRectAdFactory.placementId);
#endif
        
        [self reloadMediumRectangleWithTimeout];
        
        [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Medium Rectangle" withLabel:nil];
        
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MediumRectangle" action:@"DidLoad" label:NSStringFromClass([[self currentViewController] class]) value:0];
    } else if (adsAdapter == self.contentAdFactory) {
#if (TARGET_IPHONE_SIMULATOR)
#else
        CLS_LOG(@"adViewDidReceiveAd Content Ad %@", self.contentAdFactory.placementId);
#endif
        self.contentAd = adView;
        
        self.hasLoadedContentAd = YES;
        self.isLoadingContentAd = NO;
        
        if ([self.contentAdFactory.placementId isEqualToString:[[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdContentBanner]]) {
            if (adView.frame.size.height > kParalaxFallbackHeightMax) {//limiting height to 100 px
                //[[AdManager sharedAdManager] adViewDidFailToLoadAd:[AdManager sharedAdManager].contentAd];
                self.contentAd = nil;
                self.hasLoadedContentAd = NO;
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MNGInFeedCustomEvent" action:@"fallbackAdRejectedForHeight" label:@"" value:0];
                return;
            } else {
                CGRect frame = adView.frame;
                frame.size = kContentAdFallbackRect.size;
                adView.frame = frame;
                [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MNGInFeedCustomEvent" action:@"fallbackAdLoaded" label:@"" value:0];
            }
        }
        
        //frame.size.height = bannerView
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedContentAd object:nil];
        
        [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Content" withLabel:nil];
        
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"ContentAd" action:@"DidLoad" label:NSStringFromClass([[self currentViewController] class]) value:0];
    } else if (adsAdapter == self.overlayAdFactory) {
        self.overlayAd = adView;
        
        //ADD BLACK SCREEN
        self.overlayBannerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height)];
        self.overlayBannerContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        UIButton * button = [[UIButton alloc] initWithFrame:self.overlayBannerContainer.frame];
        [button addTarget:self action:@selector(closeOverlay) forControlEvents:UIControlEventTouchUpInside];
        [self.overlayBannerContainer addSubview:button];
        CGRect frame = self.overlayAd.frame;
        frame.origin.x = (self.overlayBannerContainer.frame.size.width - frame.size.width) / 2;
        frame.origin.y = (self.overlayBannerContainer.frame.size.height - frame.size.height) / 2;
        self.overlayAd.frame = frame;
        [self.overlayBannerContainer addSubview:self.overlayAd];
        self.overlayBannerContainer.alpha = 0;
        self.overlayAd.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        [self.parentViewController.view addSubview:self.overlayBannerContainer];
        
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.overlayBannerContainer.alpha = 1;
            self.overlayAd.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:nil];
        
        [self performSelector:@selector(closeOverlay) withObject:nil afterDelay:30];
        
        [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Overlay" withLabel:nil];
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Overlay" action:@"DidLoad" label:NSStringFromClass([[self currentViewController] class]) value:0];
    } else if (adsAdapter == self.fullScreenAdFactory) {
        self.fullScreenAd = adView;
        self.hasLoadedFullscreenAd = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedFullscreenAd object:nil];
        
        //BOTTOM ALIGN CHILDREN AND REPORT TYPE
        NSString * className;
        for (UIView * view in adView.subviews) {
            
            className = NSStringFromClass([view class]);
            
#if (TARGET_IPHONE_SIMULATOR)
#else
            CLS_LOG(@"%@ %@ %@", className, view, self.fullScreenAdFactory.placementId);
#endif
            
            if (_startdateLoadingAd && className) {
                [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Fullscreen banner" withLabel:className];
            }
        }
        
        if (!className) {
            className = @"Unkown";
        }
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Fullscreen" action:@"DidLoad" label:NSStringFromClass([[self currentViewController] class])/*className*/ value:0];
    }
}

-(void)adsAdapter:(MNGAdsAdapter *)adsAdapter bannerDidFailWithError:(NSError *)error {
    if (adsAdapter == self.bannerAdFactory) {
        [self reloadStandardBannerWithTimeout];
        
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Banner" action:@"DidFail" label:NSStringFromClass([[self currentViewController] class]) value:0];
    } else if (adsAdapter == self.mediumRectAdFactory) {
        [self reloadMediumRectangleWithTimeout];
        
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MediumRectangle" action:@"DidFail" label:NSStringFromClass([[self currentViewController] class]) value:0];
    } else if (adsAdapter == self.contentAdFactory) {
        if ([self.contentAdFactory.placementId isEqualToString:[[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdContent320xDynamic]]) {
            NSString * adUnitID = [[ConfigManager sharedConfigManager] stringForKey:kKeyAdUnitIdContentBanner];//ez@"/2472080/contentbanner"
            self.contentAdFactory.placementId = adUnitID;
            CGRect frame = kContentAdFallbackRect;
            [self.contentAdFactory loadBannerInFrame:frame];
            
            [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"ContentAd" action:@"DidFail" label:NSStringFromClass([[self currentViewController] class]) value:0];
        } else {
            self.isLoadingContentAd = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedContentAd object:nil];
            [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MNGInFeedCustomEvent" action:@"DidFail" label:NSStringFromClass([[self currentViewController] class]) value:0];
        }
    } else if (adsAdapter == self.fullScreenAdFactory) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedFullscreenAd object:nil];
        
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Fullscreen" action:@"DidFail" label:NSStringFromClass([[self currentViewController] class]) value:0];
    }
}

-(void)adsAdapter:(MNGAdsAdapter *)adsAdapter bannerDidChangeFrame:(CGRect)frame {
    if (adsAdapter == self.bannerAdFactory) {
    self.standardBanner.frame = frame;
    self.standardBannerContainer = [[UIView alloc] initWithFrame:frame];
    self.standardBannerContainer.backgroundColor = [UIColor whiteColor];
    self.standardBannerContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.standardBanner.frame = frame;
    [self setStandardBannerFrame];
    } else if (adsAdapter == self.mediumRectAdFactory) {
        
    } else if (adsAdapter == self.contentAdFactory) {
        self.contentAd.frame = frame;
    }
}

#pragma mark -
#pragma mark MNG Native Delegate

-(void)adsAdapter:(MNGAdsAdapter *)adsAdapter nativeObjectDidLoad:(MNGNAtiveObject *)adView {
    adsAdapter.clickDelegate = self;
    if (adsAdapter == self.nativeAdFactory) {
        self.nativeAd = adView;
        self.hasLoadedNativeAd = YES;
        self.isLoadingNativeAd = NO;
        
        //HIDE NORMAL BANNER ON iPad
        if (isiPad) {
            [self hideStandardBanner];
        }
        
#if (TARGET_IPHONE_SIMULATOR)
#else
        CLS_LOG(@"adViewDidReceiveAd Native Ad %@", self.nativeAdFactory.placementId);
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *titleForAd = adView.title;
            
            self.nativeAdView = [[[NSBundle mainBundle] loadNibNamed:@"FacebookNativeCollectionViewAd"
                                                                  owner:self
                                                                options:nil] firstObject];
            UILabel *titleLabel = (UILabel*)[_nativeAdView viewWithTag:1];
            UILabel *subtitleLabel = (UILabel*)[_nativeAdView viewWithTag:2];

            UIView *adCoverMediaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 190)];
            [adView setMediaContainer:adCoverMediaView];
            
            titleLabel.text = titleForAd;
            subtitleLabel.text = ONALocalizedString(@"Werbung", nil);
            
            [_nativeAdView addSubview:adCoverMediaView];
            [_nativeAdView addSubview:adView.badgeView];
            
            //FBAdChoicesView * adChoisesView = [[FBAdChoicesView alloc] initWithNativeAd:nativeAd expandable:YES];
            //[nativeAdView addSubview:adChoisesView];
            //[adChoisesView updateFrameFromSuperview];
            
            // Register the native ad view and its view controller with the native ad instance
            UIViewController *viewController = AppDelegate.tabBarController.selectedViewController;
            if ([viewController respondsToSelector:@selector(topViewController)]) {
                viewController = [(UINavigationController *)viewController topViewController];
            }
            
            [adView registerViewForInteraction:_nativeAdView
                            withViewController:viewController
                             withClickableView:(UIView*)[_nativeAdView viewWithTag:4]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedNativeAd object:nil];
        });
        
        [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Native" withLabel:nil];
        
        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"NativeAd" action:@"DidLoad" label:NSStringFromClass([[self currentViewController] class]) value:0];

    }
}

-(void)adsAdapter:(MNGAdsAdapter *)adsAdapter nativeObjectDidFailWithError:(NSError *)error {
    if (adsAdapter == self.nativeAdFactory) {
            //DO NOT DO THAT -> IF WE HAD HAD AN AD, WE WILL SHOW IT
            //self.hasLoadedNativeAd = NO;
            self.isLoadingNativeAd = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedNativeAd object:nil];
            
            [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"NativeAd" action:@"DidFail" label:NSStringFromClass([[self currentViewController] class]) value:0];
            
        }
}

#pragma mark -
#pragma mark MNG Interstitial Delegate

-(void)adsAdapterInterstitialDidLoad:(MNGAdsAdapter *)adsAdapter {
#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"%@", adsAdapter);
#endif
    adsAdapter.clickDelegate = self;
        self.hasLoadedInterstitial = YES;
        
        NSString * className;
//        if (_startdateLoadingAd && interstitial.view.subviews && interstitial.view.subviews.count > 0) {
//            UIView *view = interstitial.view.subviews[0];
//            NSString * className = NSStringFromClass([view class]);
//            if (className) {
//                [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Interstitial" withLabel:className];
//            }
//        }
        
        if (!className) {
            className = @"Unkown";
        }
    [[TrackingManager sharedTrackingManager] trackGoogleTimingInCategory:@"Ads" withTimeInterval:[[NSDate date] timeIntervalSinceDate:_startdateLoadingAd] withName:@"Interstitial" withLabel:className];

        [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Interstitial" action:@"DidLoad" label:/*className*/NSStringFromClass([[self currentViewController] class]) value:0];
    
    //[self showInterstitial];
}

-(void)adsAdapter:(MNGAdsAdapter *)adsAdapter interstitialDidFailWithError:(NSError *)error {
#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"%@", adsAdapter);
#endif
    
    
    [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Interstitial" action:@"DidFail" label:NSStringFromClass([[self currentViewController] class]) value:0];
}

-(void)adsAdapterInterstitialDisappear:(MNGAdsAdapter *)adsAdapter {
#if (TARGET_IPHONE_SIMULATOR)
#else
    CLS_LOG(@"");
#endif
    
        //[self loadStandardBannerFromTimer:YES];
        
    self.interstitialAdFactory = nil;
    self.hasLoadedInterstitial = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedStandardAd object:nil];
    
    [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Interstitial" action:@"interstitialDidDisappear" label:NSStringFromClass([[self currentViewController] class]) value:0];
}

#pragma mark -
#pragma mark Mopub Delegate

- (UIViewController *)viewControllerForPresentingModalView {
	return self.parentViewController;
}
//
//- (void)willPresentModalViewForAd:(MPAdView *)bannerView {
//
//#if (TARGET_IPHONE_SIMULATOR)
//#else
//	CLS_LOG(@"%@", bannerView);
//#endif
//
//	if (bannerView == self.standardBanner) {
//		[[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Banner" action:@"WillPresentModalViewForAd" label:NSStringFromClass([[self currentViewController] class]) value:0];
//	}
//
//	if (bannerView == self.mediumRectangle) {
//		[[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MediumRectangle" action:@"WillPresentModalViewForAd" label:NSStringFromClass([[self currentViewController] class]) value:0];
//	}
//
//	int incrementUserClickedOnAd = [self incrementUserClickedOnAd];
//}
//
//- (void)willLeaveApplicationFromAd:(MPAdView *)bannerView {
//
//#if (TARGET_IPHONE_SIMULATOR)
//#else
//	CLS_LOG(@"%@", bannerView);
//#endif
//
//	if (bannerView == self.standardBanner) {
//		[[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Banner" action:@"willLeaveApplicationFromAd" label:NSStringFromClass([[self currentViewController] class]) value:0];
//	}
//
//	if (bannerView == self.mediumRectangle) {
//		[[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"MediumRectangle" action:@"willLeaveApplicationFromAd" label:NSStringFromClass([[self currentViewController] class]) value:0];
//	}
//
//	int incrementUserClickedOnAd = [self incrementUserClickedOnAd];
//
//	if (bannerView == self.overlayAd) {
//
//		[[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Overlay" action:@"willLeaveApplicationFromAd" label:NSStringFromClass([[self currentViewController] class]) value:0];
//		[self closeOverlay];
//	}
//}

- (int) incrementUserClickedOnAd {

	int numberOfAdsClicked = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfAdsClicked"];
	numberOfAdsClicked++;
	[[NSUserDefaults standardUserDefaults] setInteger:numberOfAdsClicked forKey:@"numberOfAdsClicked"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	return numberOfAdsClicked;

}
//
//- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
//
//	int incrementUserClickedOnAd = [self incrementUserClickedOnAd];
//	[[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Interstitial" action:@"interstitialDidReceiveTapEvent" label:NSStringFromClass([[self currentViewController] class]) value:0];
//}
//
//- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
//
//#if (TARGET_IPHONE_SIMULATOR)
//#else
//	CLS_LOG(@"");
//#endif
//
//    [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Interstitial" action:@"interstitialWillAppear" label:NSStringFromClass([[self currentViewController] class]) value:0];
//
//}
//
//- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
////- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
//
//#if (TARGET_IPHONE_SIMULATOR)
//#else
//	CLS_LOG(@"");
//#endif
//
//	if (interstitial == self.interstitial) {
//
//		//[self loadStandardBannerFromTimer:YES];
//
//		self.interstitial = nil;
//		self.hasLoadedInterstitial = NO;
//	}
//
//	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadedStandardAd object:nil];
//
//    [[TrackingManager sharedTrackingManager] trackEventForAdLogging:@"Interstitial" action:@"interstitialDidDisappear" label:NSStringFromClass([[self currentViewController] class]) value:0];
//}

#pragma mark - Positioning

- (UIView*) standardBannerContainerForTableViewCell {
	self.standardBannerContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	return self.standardBannerContainer;
}

- (UIView*) standardBannerContainerForBottom {
	self.standardBannerContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	self.standardBannerContainer.frame = CGRectMake(self.standardBannerContainer.frame.origin.x, self.standardBannerContainer.frame.origin.y, self.standardBanner.frame.size.width, self.standardBanner.frame.size.height);
	return self.standardBannerContainer;
}

- (void) setStandardBannerFrame {

    if (!self.standardBannerContainer) {
        return;
    }

	if (self.currentViewController.usesScrollingAds) {
		// Center banner in container
		CGRect frame = self.standardBanner.frame;
		frame.origin.x = (self.standardBannerContainer.frame.size.width - frame.size.width) / 2;
		self.standardBanner.frame = frame;
		return;
	}

	[self standardBannerContainerForBottom];

	//SET POSITION
	double startY = [UIScreen mainScreen].bounds.size.height / self.parentViewController.view.transform.a; // Adjust for zoom
	double endY = [UIScreen mainScreen].bounds.size.height / self.parentViewController.view.transform.a - self.standardBanner.frame.size.height;

	if (isiPad) {
		endY -= 49;
	}

	//SET X
	CGRect frame = self.standardBannerContainer.frame;
	//NO NEED TO MOVE IN IF BANNER IS THERE ALREADY
	if (round(frame.origin.y) != round(endY) || (!(isiPad) && self.standardBannerContainer.superview != self.parentViewController.view)) {
		frame.origin.y = startY;
	}
    if (self.standardBannerContainer.superview) {
        [self.standardBannerContainer removeFromSuperview];
    }
	frame.origin.x = 0;
	frame.size.width = [UIScreen mainScreen].bounds.size.width;
	self.standardBannerContainer.frame = frame;
	//AD BACK TO CURRENT VIEW
	[self.parentViewController.view addSubview:self.standardBannerContainer];

	frame = self.standardBanner.frame;
	frame.origin.x = (self.standardBannerContainer.frame.size.width - self.standardBanner.frame.size.width) / 2;
	self.standardBanner.frame = frame;
}

- (void) animateStandardBannerIn {

	//CLS_LOG(@"");
    
	[self setStandardBannerFrame];

	if (self.currentViewController.usesScrollingAds) {
		return;
	}

	//PARENT
	double endY = self.parentViewController.view.frame.size.height / self.parentViewController.view.transform.a - self.standardBannerContainer.frame.size.height;
	if (isiPad) {
		endY -= 49;
	}

	//MOVE UP
	[UIView animateWithDuration:0.25 animations:^{

		CGRect frame2 = self.standardBannerContainer.frame;
		frame2.origin.y = endY;
		self.standardBannerContainer.frame = frame2;
        if ([self.currentViewController isKindOfClass:[GridViewController class]]) {
            GridViewController *gridVC = (GridViewController *)self.currentViewController;
            UIEdgeInsets edgeInsets = ((UIScrollView *)gridVC.gridScrollView).contentInset;
            edgeInsets.bottom = self.standardBannerContainer.frame.size.height;
            [(UIScrollView *)gridVC.gridScrollView setContentInset:edgeInsets];
        }
	}];

	//CLS_LOG(@"%@", self.standardBanner);
}

- (void) addScreenshotToBackgroundOfStandardBanner {

	UIGraphicsBeginImageContextWithOptions(self.standardBanner.bounds.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self.standardBanner.layer renderInContext:context];
	UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	UIColor *background = [[UIColor alloc] initWithPatternImage:screenShot];
	self.standardBanner.backgroundColor = background;
}

- (void) addBackgroundColorToAdBackground {

	if (self.standardBanner.superview) {

		UIGraphicsBeginImageContextWithOptions(self.standardBanner.bounds.size, NO, [UIScreen mainScreen].scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[self.standardBanner.layer renderInContext:context];
		UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		UIColor *backgroundColor = [screenShot averageColor];

		[UIView animateWithDuration:0.25 animations:^{
			self.standardBanner.superview.backgroundColor = backgroundColor;
		}];
	}
}

- (UIView*) contentAdContainerForTableViewCell {
    self.contentAdContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    return self.contentAdContainer;
}

- (void) setContentAdFrame {
    
    if (!self.contentAdContainer) {
        return;
    }
    
    CGRect frame = self.contentAd.frame;
    frame.origin.x = ([UIScreen mainScreen].bounds.size.width - frame.size.width) / 2;
    self.contentAd.frame = frame;
    return;
}

- (void) addScreenshotToBackgroundOfContentAd {
    
    UIGraphicsBeginImageContextWithOptions(self.contentAd.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.contentAd.layer renderInContext:context];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:screenShot];
    self.contentAdContainer.backgroundColor = background;
}

@end
