//
//  EcomapFetcher.h
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EcomapURLFetcher.h"

#import "EcomapPathDefine.h"
#import "EcomapURLFetcher.h"
#import "JSONparser.h"
#import "NetworkActivityIndicator.h"

//Value-Object classes
#import "EcomapProblem.h"
#import "EcomapProblemDetails.h"
#import "EcomapEditableProblem.h"
#import "EcomapLoggedUser.h"
#import "EcomapPhoto.h"
#import "EcomapActivity.h"
#import "EcomapResources.h"
#import "EcomapAlias.h"
#import "EcomapCommentaries.h"
//#import "LocalImageDescription.h"
#import "AddCommViewController.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"
#import "DataTasks.h"

@import MobileCoreServices;

@class EcomapLoggedUser;
@class EcomapProblemDetails;
@class EcomapEditableProblem;
@class EcomapProblem;
@class EcomapCommentaries;

@interface EcomapFetcher : NSObject

#pragma mark - GET API
//Load all problems to array in completionHandler not blocking the main thread
//NSArray *problems is a collection of EcomapProblem objects;

+ (void)loadEverything;
+ (void) updateData;

+ (void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler;
+(void)checkRevision:(void (^)(BOOL differance, NSError *error))completionHandler;
+(void)loadProblemsDifference:(void (^)(NSArray *problems, NSError *error))completionHandler;
//+(BOOL)updateComments:(NSUInteger)problemID;
+(void)loadAllProblemsDescription:(void (^)(NSArray *problems, NSError *error))completionHandler;


//Load problem details not blocking the main thread
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler;

// Load alias of resources (its a path to details of resources)
+(void)loadAliasOnCompletion:(void (^)(NSArray *alias, NSError *error))completionHandler String:(NSString*)str;

//Load tittles of resources not blocking the main thread
+(void)loadResourcesOnCompletion:(void (^)(NSArray *resources, NSError *error))completionHandler;
// Load all alias content
+ (void)registerToken:(NSString *)token
         OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler;
//POST method for votes
+ (void)addVoteForProblem:(EcomapProblemDetails *)problemDetails withUser:(EcomapLoggedUser *)user OnCompletion:(void (^)(NSError *error))completionHandler;

+(void)createComment:(NSString*)userId andName:(NSString*)name
          andSurname:(NSString*)surname andContent:(NSString*)content andProblemId:(NSString*)probId
        OnCompletion:(void (^)(EcomapCommentaries *obj,NSError *error))completionHandler;

+(void)loadCommentsFromWeb:(NSUInteger)problemID;

+ (void)addCommentToProblem:(NSInteger)problemID withContent:(NSString *)content
               onCompletion:(void (^)(NSError *error))completionHandler;
+ (void)deleteComment:(NSInteger)commentID onCompletion:(void (^)(NSError *error))completionHandler;
+ (void)editComment:(NSInteger)commentID withContent:(NSString *)content
       onCompletion:(void (^)(NSError *error))completionHandler;
+ (BOOL)updateComments:(NSUInteger)problemID controller:(AddCommViewController*)controller;
+ (void)getProblemWithComments;

+ (void)editProblem:(EcomapProblemDetails *)problem
        withProblem:(EcomapEditableProblem *)editableProblem
       onCompletion:(void (^)(NSError *error))completionHandler;
+ (void)deleteProblem:(NSUInteger)problemID
         onCompletion:(void (^)(NSError *error))completionHandler;
@end
