//
//  EcomapFetcher+PostProblem.m
//  ecomap
//
//  Created by Anton Kovernik on 03.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapFetcher+PostProblem.h"
#import "EcomapLocalPhoto.h"
#import "AFNetworking.h"
#import "MapViewController.h"
#import "EcomapRevisionCoreData.h"

@implementation EcomapFetcher (PostProblem)

#pragma mark - POST API

+ (void)problemPost:(EcomapProblem*)problem
     problemDetails:(EcomapProblemDetails*)problemDetails
               user:(EcomapLoggedUser*)user
       OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler
{
    NSDictionary *params = @{
                          // @"severity" : @(problemDetails.severity),
                             @"title"     : problem.title,
                             @"content"    : problemDetails.content,
                             @"proposal" : problemDetails.proposal,
                             @"latitude" : @(problem.latitude),
                             @"longitude" : @(problem.longitude),
                             @"problem_type_id" : @(problem.problemTypesID)
                             
                             };
    
        [[NetworkActivityIndicator sharedManager] startActivity];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        [manager setRequestSerializer:jsonRequestSerializer];
    
        [manager POST:ECOMAP_PROBLEM_POST_ADDRESS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            EcomapRevisionCoreData *revision = [[EcomapRevisionCoreData alloc] init];
            [revision checkRevison:nil];
           
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
            NSLog(@"%@",error);
        }];
     dispatch_async(dispatch_get_main_queue(), ^{
     [[NetworkActivityIndicator sharedManager]endActivity];
    });
    
    }

+ (void)addPhotos:(NSArray*)photos
        toProblem:(NSUInteger)problemId
             user:(EcomapLoggedUser*)user
     OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler
{
    if (!user || photos.count == 0)
    {
        completionHandler(nil, [NSError errorWithDomain:@"Fetcher"
                                                   code:2
                                               userInfo:@{
                                                          NSLocalizedDescriptionKey: @"Error"
                                                          }]);
        return;
    }
    NSDictionary *params = @{
                             @"userId" : @(user.userID),
                             @"userName" : user.name,
                             @"userSurname" : user.surname,
                             @"solveProblemMark": @"off",
                             };
    NSString *boundary = [EcomapFetcher generateBoundaryString];
    
    // configure the request
    NSURL *url = [[EcomapURLFetcher URLforPostPhoto] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", @(problemId)]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    // set content type
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // create body
    NSData *httpBody = [EcomapFetcher createBodyWithBoundary:boundary
                                                  parameters:params
                                                      photos:photos];
    
    NSURLSession *session = [NSURLSession sharedSession];  // use sharedSession or create your own
    NSURLSessionTask *task = [session uploadTaskWithRequest:request
                                                   fromData:httpBody
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                              {
                                  if (error)
                                  {
                                      DDLogVerbose(@"error = %@", error);
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          completionHandler(nil, error);
                                      });
                                      return;
                                  }
                                  NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                  DDLogVerbose(@"result = %@", result);
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      completionHandler(result, error);
                                  });
                              }];
    [task resume];
}

+ (NSData*)stringToData:(NSString *)formatString, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list args;
    va_start(args, formatString);
    NSString *contents = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
    return [contents dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData*)createBodyWithBoundary:(NSString*)boundary
                       parameters:(NSDictionary*)parameters
                           photos:(NSArray*)photos
{
    NSMutableData *httpBody = [NSMutableData data];
    NSData *boundaryData = [EcomapFetcher stringToData:@"--%@\r\n", boundary];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:boundaryData];
        [httpBody appendData:[EcomapFetcher stringToData:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey]];
        [httpBody appendData:[EcomapFetcher stringToData:@"%@\r\n", parameterValue]];
    }];
    
    NSLog(@"%@", [[NSString alloc] initWithData:httpBody encoding:NSUTF8StringEncoding]);
    
    [photos enumerateObjectsUsingBlock:^(EcomapLocalPhoto *descr, NSUInteger idx, BOOL *stop) {
        [httpBody appendData:boundaryData];
        [httpBody appendData:[EcomapFetcher stringToData:@"Content-Disposition: form-data; name=\"description\";\r\n\r\n"]];
        if ([descr.imageDescription isKindOfClass:[NSString class]]) {
            [httpBody appendData:[EcomapFetcher stringToData:@"%@\r\n", descr.imageDescription]];
        } else {
            [httpBody appendData:[EcomapFetcher stringToData:@"\r\n"]];
        }
        
        NSString *filename  = [NSString stringWithFormat:@"%lu.jpg", (unsigned long)idx];
        NSData   *data      = UIImageJPEGRepresentation(descr.image, 0.8);
        DDLogInfo(@"Image size: %@", @(data.length));
        NSString *mimetype  = [EcomapFetcher mimeTypeForPath:filename];
        
        [httpBody appendData:boundaryData];
        [httpBody appendData:[EcomapFetcher stringToData:@"Content-Disposition: form-data; name=\"file[%lu]\"; filename=\"%@\"\r\n",
                              (unsigned long)idx,
                              filename]];
        [httpBody appendData:[EcomapFetcher stringToData:@"Content-Type: %@\r\n\r\n", mimetype]];
        [httpBody appendData:data];
        [httpBody appendData:[EcomapFetcher stringToData:@"\r\n"]];
    }];
    
    [httpBody appendData:[EcomapFetcher stringToData:@"--%@--\r\n", boundary]];
    NSLog(@"%@", [[NSString alloc] initWithData:httpBody encoding:NSUTF8StringEncoding]);
    return httpBody;
}

+ (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

+ (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

@end
