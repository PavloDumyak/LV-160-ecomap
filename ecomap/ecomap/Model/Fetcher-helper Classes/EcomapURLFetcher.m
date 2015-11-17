//
//  EcomapURLFetcher.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapURLFetcher.h"
#import "EcomapPathDefine.h"

@implementation EcomapURLFetcher

+ (NSURL *)URLforRevison
{
    NSMutableString *base = [NSMutableString stringWithFormat:ECOMAP_ADDRESS_FOR_REVISON];
    NSString *currentRevision = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"revision"]];
    [base  appendString:currentRevision];
    return [NSURL URLWithString:base];
}

+ (NSString *)URLforAddComment:(NSInteger)problemId
{
    NSMutableString *addCommentUrl = [NSMutableString stringWithString:ECOMAP_ADDRESS];
    [addCommentUrl appendString:ECOMAP_API];
    [addCommentUrl appendString:ECOMAP_GET_PROBLEM_API];
    [addCommentUrl appendFormat:@"/%ld",(long)problemId];
    [addCommentUrl appendString:ECOMAP_ADD_COMMENT];
    return addCommentUrl;
}

+(NSString *)URLforChangeComment:(NSInteger)commentId
{
    NSMutableString *changeCommentUrl = [NSMutableString stringWithString:ECOMAP_ADDRESS];
    [changeCommentUrl appendString:ECOMAP_API];
    [changeCommentUrl appendString:ECOMAP_CHANGE_COMMENTS];
    [changeCommentUrl appendFormat:@"%ld",(long)commentId];
    return changeCommentUrl;
    
}

+ (NSString *)URLforEditingProblem:(NSUInteger)problemID
{
    NSString* baseUrl = [ECOMAP_ADDRESS stringByAppendingFormat:@"%@%@", ECOMAP_API, ECOMAP_GET_PROBLEM_API];
    return [baseUrl stringByAppendingFormat:@"/%lu", problemID];
}

#pragma mark - Form final URL
//Add Server adress
+ (NSURL *)URLForQuery:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@%@", ECOMAP_ADDRESS, query];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:query];
}

//Add API address
+ (NSURL *)URLForAPIQuery:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@%@", ECOMAP_API, query];
    return [self URLForQuery:query];
}

#pragma mark - Ask URL methods
+ (NSURL *)URLforAllProblems
{
    return [self URLForAPIQuery:ECOMAP_GET_PROBLEM_API];
}

+ (NSURL *)URLforAllProblemsTypes
{
    return [self URLForAPIQuery:ECOMAP_GET_PROBLEM_TYPES];
}

+ (NSURL *)URLforProblemWithID:(NSUInteger)problemID
{
    NSString *query = [NSString stringWithFormat:@"%@%lu", ECOMAP_GET_PROBLEMS_WITH_ID_API, (unsigned long)problemID];
    return [self URLForAPIQuery:query];
}

+ (NSURL *)ProblemDescription;
{
    
    NSString *query = [NSString stringWithFormat:@"%@", ECOMAP_GET_PROBLEM_API];
    return [self URLForAPIQuery:query];
}


+ (NSURL *)URLforLogin
{
    return [self URLForAPIQuery:ECOMAP_POST_LOGIN_API];
}

+ (NSURL *)URLforTokenRegistration
{
    return [self URLForAPIQuery:ECOMAP_POST_TOKEN_REGISTRATION];
}


+ (NSURL *)URLforLogout
{
    return [self URLForAPIQuery:ECOMAP_GET_LOGOUT_API];
}

+ (NSURL *)URLforServer
{
    return [self URLForQuery:@""];
}

+ (NSString *)serverDomain
{
    NSString *domain = [ECOMAP_ADDRESS stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    domain = [domain stringByReplacingOccurrencesOfString:@":8090" withString:@""];
    
    return [domain stringByReplacingOccurrencesOfString:@"/" withString:@""];
}

+ (NSURL *)URLforTopChartsOfProblems
{
    return [self URLForAPIQuery:ECOMAP_GET_TOP_CHARTS_OF_PROBLEMS];
}

+ (NSURL *)URLforLargePhotoWithLink:(NSString *)link
{
    return [self URLForQuery:[ECOMAP_GET_LARGE_PHOTOS_ADDRESS stringByAppendingString:link]];
}

+ (NSURL *)URLforSmallPhotoWithLink:(NSString *)link
{
    return [self URLForQuery:[ECOMAP_GET_SMALL_PHOTOS_ADDRESS stringByAppendingString:link]];
}

#pragma mark - Ask URL for Register
// added by Gregory Chereda
+(NSURL*)URLforRegister{
    return [self URLForAPIQuery:ECOMAP_POST_REGISTER_API];
}

+(NSURL *)URLforChangePassword
{
    return [self URLForAPIQuery:ECOMAP_POST_CHANGEPASSWORD_API];
}

#pragma mark -
+ (NSURL *)URLforStatsForParticularPeriod:(EcomapStatsTimePeriod)period
{
    switch(period) {
        case EcomapStatsForAllTheTime: return [self URLForAPIQuery:ECOMAP_GET_STATS_FOR_ALL_THE_TIME];
        case EcomapStatsForLastYear: return [self URLForAPIQuery:ECOMAP_GET_STATS_FOR_LAST_YEAR];
        case EcomapStatsForLastMonth: return [self URLForAPIQuery:ECOMAP_GET_STATS_FOR_LAST_MOTH];
        case EcomapStatsForLastWeek: return [self URLForAPIQuery:ECOMAP_GET_STATS_FOR_LAST_WEEK];
        case EcomapStatsForLastDay: return [self URLForAPIQuery:ECOMAP_GET_STATS_FOR_LAST_DAY];
    }
}

+ (NSURL *)URLforGeneralStats
{
    return [self URLForAPIQuery:ECOMAP_GET_GENERAL_STATS];
}

+ (NSURL *)URLforProblemPost
{
    return [self URLForAPIQuery:ECOMAP_POST_PROBLEM];
}

+ (NSURL *)URLforPostPhoto
{
    return [self URLForAPIQuery:ECOMAP_POST_PHOTO];
}

+ (NSURL *)URLforPostVotes
{
    return [self URLForAPIQuery:ECOMAP_POST_VOTE];
}
#pragma mark - Ask URL for all resources
+(NSURL *)URLforResources
{
    return [self URLForAPIQuery:ECOMAP_GET_RESOURCES];
}

+(NSURL*)URLforAlias:(NSString*)query
{
    query = [NSString stringWithFormat:@"%@%@",[self URLForAPIQuery:ECOMAP_GET_ALIAS],query];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [NSURL URLWithString:query];
}
#pragma mark - Ask URL for Comments
+ (NSURL*) URLforComments:(NSString *)query
{ query =[NSString stringWithFormat:@"%@%@",[self URLForAPIQuery:ECOMAP_POST_COMMENT],query];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:query];
}


+(NSURL*)URLforDeletingPhoto:(NSString*)link
{
    NSString *query = [ECOMAP_POST_PHOTO stringByAppendingString:link];
                       return [self URLForAPIQuery:query];
}
@end
