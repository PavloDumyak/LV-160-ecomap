//
//  EcomapPhoto.h
//  ecomap
//
//  Created by Inna Labuskaya on 2/10/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapPhoto : NSObject

@property (nonatomic, readonly) NSUInteger photoID;
@property (nonatomic, strong, readonly) NSString *link;
@property (nonatomic, readonly) BOOL isSolved;
@property (nonatomic, strong, readonly) NSString *caption;
@property (nonatomic, readonly) NSUInteger problemsID;
@property (nonatomic, readonly) NSUInteger usersID;

//Designated initializer
-(instancetype)initWithInfo:(NSDictionary *)problem;

@end
