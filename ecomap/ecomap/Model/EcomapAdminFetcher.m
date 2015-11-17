//
//  ECMAdminFetcher.m
//  ecomap
//
//  Created by ohuratc on 02.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapAdminFetcher.h"
#import "EcomapLoggedUser.h"
#import "EcomapURLFetcher.h"
#import "DataTasks.h"
#import "JSONParser.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation EcomapAdminFetcher

+(void)deletePhotoWithLink:(NSString*)link onCompletion:(void(^)(NSError *error))completionHandler
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforDeletingPhoto:link]];
    [request setHTTPMethod:@"DELETE"];
    [DataTasks dataTaskWithRequest:request sessionConfiguration:sessionConfiguration completionHandler:^(NSData *JSON, NSError *error) {
        if(error)
            DDLogVerbose(@"ERROR: %@", error);
        completionHandler(error);
    }];

    
}

// Utility method. Convert BOOL to NSNumber.
+ (NSNumber *)BOOLtoInteger:(BOOL)flag
{
    return flag ? @1 : @0;
}

@end
