 //
//  DataTasks.m
//  ecomap
//
//  Created by Vasya on 2/28/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "DataTasks.h"
#import "NetworkActivityIndicator.h"
#import "EcomapPathDefine.h"

#import "Reachability.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation DataTasks
#pragma mark - Data tasks
//Data task
+(void)dataTaskWithRequest:(NSURLRequest *)request sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    //Ckeck internet connection
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0)
    {
        completionHandler (nil, [self errorForStatusCode:NO_INTERNET_CODE]);
        return;
    }

    [[NetworkActivityIndicator sharedManager] startActivity];
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform download task on different thread
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSData *JSON = nil;
                                                if (!error)
                                                {
                                                    //Set data
                                                    if ([self statusCodeFromResponse:response] == 200)
                                                    {
                                                        //Log to console
                                                        DDLogVerbose(@"Data task performed success from URL: %@", request.URL);
                                                        JSON = data;
                                                        error = 0;
                                                    }
                                                    else
                                                    {
                                                        //Create error message
                                                        error = [self errorForStatusCode:[self statusCodeFromResponse:response]];
                                                    }
                                                }
                                                //Perform completionHandler task on main thread
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    completionHandler(JSON, error);
                                                    [[NetworkActivityIndicator sharedManager]endActivity];
                                                    
                                                });
                                                
                                            }];
    
    [task resume];
    
}

//Download data task
+(void)downloadDataTaskWithRequest:(NSURLRequest *)request sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *data, NSError *error))completionHandler
{
    //Ckeck internet connection
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0)
    {
        completionHandler (nil, [self errorForStatusCode:NO_INTERNET_CODE]);
        return;
    }
    
    [[NetworkActivityIndicator sharedManager] startActivity];
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform download task on different thread
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                        
                                                        NSData *data = nil;
                                                        if (!error)
                                                        {
                                                            //Set data
                                                            if ([self statusCodeFromResponse:response] == 200)
                                                            {
                                                                //Log to console
                                                                DDLogVerbose(@"Download data task performed success from URL: %@", request.URL);
                                                                data = [NSData dataWithContentsOfURL:location];;
                                                            }
                                                            else
                                                            {
                                                                //Create error message
                                                                error = [self errorForStatusCode:[self statusCodeFromResponse:response]];
                                                            }
                                                        }
                                                        //Perform completionHandler task on main thread
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            completionHandler(data, error);
                                                            [[NetworkActivityIndicator sharedManager]endActivity];
                                                        });
                                                        
                                                    }];
    
    
    [task resume];
    
}

//Upload data task
+(void)uploadDataTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)data sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    //Ckeck internet connection
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0)
    {
        completionHandler (nil, [self errorForStatusCode:NO_INTERNET_CODE]);
        return;
    }
    
    [[NetworkActivityIndicator sharedManager] startActivity];
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform upload task on different thread
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSData *JSON = nil;
        if (!error)
        {
            //Set data
            if ([self statusCodeFromResponse:response] == 200)
            {
                //Log to console
                DDLogVerbose(@"Upload task performed success to url: %@", request.URL);
                JSON = data;
            }
            else
            {
                //Create error message
                error = [self errorForStatusCode:[self statusCodeFromResponse:response]];
                JSON = data;
            }
        }
        //Perform completionHandler task on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(JSON, error);
            [[NetworkActivityIndicator sharedManager]endActivity];
        });
    }];
    [task resume];
    
}

#pragma mark - Helper methods
+(NSInteger)statusCodeFromResponse:(NSURLResponse *)response
{
    //Cast an instance of NSHTTURLResponse from the response and use its statusCode method
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    return httpResponse.statusCode;
}

//Form error for different status code. (Fill more case: if needed)
+(NSError *)errorForStatusCode:(NSInteger)statusCode
{
    
    NSError *error = nil;
    switch (statusCode)
    {
        case 400:
            error = [[NSError alloc] initWithDomain:@"Bad Request" code:statusCode userInfo:@{@"error" : @"Incorect email or password"}];
            break;
            
        case 401: // added by Gregory Chereda
            error = [[NSError alloc] initWithDomain:@"Unauthorized" code:statusCode userInfo:@{@"error" : @"Request error"}];
            break;
            
        case 404:
            error = [[NSError alloc] initWithDomain:@"Not Found" code:statusCode userInfo:@{@"error" : @"The server has not found anything matching the Request URL"}];
            break;
            
        case 500:
        case 501:
        case 502:
        case 503:
        case 504:
        case 505:
        case 506:
        case 507:
        case 508:
        case 509:
        case 510:
        case 511:
            error = [[NSError alloc] initWithDomain:@"Server Error" code:statusCode userInfo:@{@"error" : @"Server Error"}];
            break;
        
        //custome code for no Internet
        case NO_INTERNET_CODE:
            error = [[NSError alloc] initWithDomain:@"No internet connection" code:statusCode userInfo:@{@"error" : @"No internet connection"}];
            break;
            
        default:
            error = [[NSError alloc] initWithDomain:@"Unknown" code:statusCode userInfo:@{@"error" : @"Unknown error"}];
            break;
    }
    return error;
}

@end
