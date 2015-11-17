//
//  JSONparser.h
//  ecomap
//
//  Created by Vasya on 2/28/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONParser : NSObject
+ (NSArray *)parseJSONtoArray:(NSData *)JSON;

//Parse JSON data to Dictionary
+ (NSDictionary *)parseJSONtoDictionary:(NSData *)JSON;
@end
