//
//  RateOverlayAd.m
//  ON AIR
//
//  Created by Eugène Peschard on 07/11/2017.
//  Copyright © 2017 stanwood UG. All rights reserved.
//

#import "RateOverlayAd.h"
#import "AdManager.h"
#import "ConfigManager.h"

@implementation RateOverlayAd

@synthesize textLabel;

- (id) initWithCoder:(NSCoder *)decoder {

    self = [super initWithCoder:decoder];
    if (self) {

        self.frame = CGRectMake(0, 0, 300, 450);
        self.layer.cornerRadius = 8.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (IBAction)closeAd:(id)sender {
    AdManager *adManager = [[AdManager alloc] init];
    [adManager closeOverlay];
}
- (IBAction)rateApp:(id)sender {
    // itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(1081797746)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software)"
//    "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=336137568&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    NSString *rateMeUrl = [[ConfigManager sharedConfigManager] stringForKey:kKeyRateMeUrl];
    // itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=336137568
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rateMeUrl]];

    AdManager *adManager = [[AdManager alloc] init];
    [adManager closeOverlay];
}

@end
