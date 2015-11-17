//
//  EcomapURLFetcher.h
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import <Foundation/Foundation.h>

// Time periods to get stats url
typedef enum {
    EcomapStatsForAllTheTime,
    EcomapStatsForLastYear,
    EcomapStatsForLastMonth,
    EcomapStatsForLastWeek,
    EcomapStatsForLastDay
} EcomapStatsTimePeriod;

@interface EcomapURLFetcher : NSObject

+ (NSString*)URLforAddComment:(NSInteger)problemId;

+ (NSURL *)URLforRevison;

+ (NSString *)URLforChangeComment:(NSInteger)commentId;

+ (NSURL *)URLforTokenRegistration;

//Return server domain
+ (NSString *)serverDomain;

//Return URL to servet
+ (NSURL *)URLforServer;

//Return API URL to get all problems
+ (NSURL *)URLforAllProblems;

//Return API URL to get problem with ID
+ (NSURL *)URLforProblemWithID:(NSUInteger)problemID;

//Return API URL to logIn
+ (NSURL *)URLforLogin;

//Return API URL to logout
+ (NSURL *)URLforLogout;

//Return URL for top charts of problems
+ (NSURL *)URLforTopChartsOfProblems;

//Return URL for stats for particular period
+ (NSURL *)URLforStatsForParticularPeriod:(EcomapStatsTimePeriod)period;

//Return URL for general stats
+ (NSURL *)URLforGeneralStats;

//Return URL for problem post
+ (NSURL *)URLforProblemPost;

//Return URL for POST votes
+ (NSURL *)URLforPostVotes;

//Return API URL to Register
+(NSURL *)URLforRegister;

//Return API URL to Register
+(NSURL *)URLforChangePassword;

//Return URL to small photo on server
+ (NSURL *)URLforSmallPhotoWithLink:(NSString *)link;

//Return URL to large photo on server
+ (NSURL *)URLforLargePhotoWithLink:(NSString *)link;

+ (NSURL *)URLforResources;

+ (NSURL *)URLforAlias:(NSString*)query;
// Return URL for comments
+ (NSURL *)URLforComments:(NSString*)query;

+ (NSURL *)URLforPostPhoto;

+ (NSString *)URLforEditingProblem:(NSUInteger)problemID;

+ (NSURL *)URLforDeletingPhoto:(NSString*)link;

+ (NSURL *)ProblemDescription;
@end
