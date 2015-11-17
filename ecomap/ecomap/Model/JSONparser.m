//
//  JSONparser.m
//  ecomap
//
//  Created by Vasya on 2/28/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "JSONParser.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation JSONParser
#pragma mark - Parse JSON
//Parse JSON data to Array
+ (NSArray *)parseJSONtoArray:(NSData *)JSON
{
    NSArray *dataFromJSON = nil;
    NSError *error;
    id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
    if (!error)
    {
        if ([parsedJSON isKindOfClass:[NSArray class]])
        {
            dataFromJSON = (NSArray *)parsedJSON;
        }
    }
    else
    {
        DDLogError(@"Error parsing JSON data: %@", [error localizedDescription]);
    }
    
    return dataFromJSON;
}

//Parse JSON data to Dictionary
+ (NSDictionary *)parseJSONtoDictionary:(NSData *)JSON
{
    NSDictionary *dataFromJSON = nil;
    NSError *error = nil;
    id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
    if (!error)
    {
        if ([parsedJSON isKindOfClass:[NSDictionary class]])
        {
            dataFromJSON = (NSDictionary *)parsedJSON;
        }
    }
    else
    {
        DDLogError(@"Error parsing JSON data: %@", [error localizedDescription]);
    }
    
    return dataFromJSON;
}

@end
