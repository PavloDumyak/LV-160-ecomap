//
//  EcomapStatsFetcher.h
//  ecomap
//
//  Created by ohuratc on 03.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcomapURLFetcher.h"

@interface EcomapStatsFetcher : NSObject

// Load stats for particular time period to draw a pie chart in Stats View Controller
+ (void)loadStatsForPeriod:(EcomapStatsTimePeriod)period onCompletion:(void (^)(NSArray *stats, NSError *error))completionHandler;

// Load general statistics to draw top label in Stats View Controller
+ (void)loadGeneralStatsOnCompletion:(void (^)(NSArray *stats, NSError *error))completionHandler;

// Load top charts of problems to show them in Top Chart List View Controller
+ (void)loadTopChartsOnCompletion:(void (^)(NSArray *charts, NSError *error))completionHandler;

@end
