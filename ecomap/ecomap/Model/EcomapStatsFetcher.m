//
//  EcomapStatsFetcher.m
//  ecomap
//
//  Created by ohuratc on 03.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapStatsFetcher.h"
#import "EcomapURLFetcher.h"
#import "DataTasks.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation EcomapStatsFetcher

#pragma mark - Statistics Fetching

+ (void)loadDataFromURL:(NSURL *)url onCompletion:(void (^)(NSArray *, NSError *))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:url]
              sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                 completionHandler:^(NSData *JSON, NSError *error) {
                     NSArray *stats = nil;
                     if(error) {
                         DDLogError(@"Error: %@", error);
                     } else {
                         // Extract recieved data
                         if(JSON) {
                             stats = [NSJSONSerialization JSONObjectWithData:JSON
                                                                     options:0
                                                                       error:NULL];
                         }
                     }
                     // Set up completion handler
                     completionHandler(stats, error);
                 }];
}

+ (void)loadStatsForPeriod:(EcomapStatsTimePeriod)period onCompletion:(void (^)(NSArray *, NSError *))completionHandler
{
    NSURL *url = [EcomapURLFetcher URLforStatsForParticularPeriod:period];
    [EcomapStatsFetcher loadDataFromURL:url onCompletion:^(NSArray *stats, NSError *error) {
        completionHandler(stats, error);
    }];
}

+ (void)loadGeneralStatsOnCompletion:(void (^)(NSArray *, NSError *))completionHandler
{
    NSURL *url = [EcomapURLFetcher URLforGeneralStats];
    [EcomapStatsFetcher loadDataFromURL:url onCompletion:^(NSArray *stats, NSError *error) {
        completionHandler(stats, error);
    }];
}

+ (void)loadTopChartsOnCompletion:(void (^)(NSArray *, NSError *))completionHandler
{
    NSURL *url = [EcomapURLFetcher URLforTopChartsOfProblems];
    [EcomapStatsFetcher loadDataFromURL:url onCompletion:^(NSArray *stats, NSError *error) {
        completionHandler(stats, error);
    }];
}

@end
