//
//  EcomapComments.h
//  ecomap
//
//  Created by Inna Labuskaya on 2/10/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapActivity : NSObject

@property (nonatomic, readonly) NSUInteger commentID;
@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, readonly) NSUInteger activityTypes_Id;
@property (nonatomic, readonly) NSUInteger usersID;
@property (nonatomic, readonly) NSUInteger problemsID;
@property (nonatomic, readonly) NSString *problemContent;
@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *userSurname;

//Designated initializer
-(instancetype)initWithInfo:(NSDictionary *)problem;

@end
