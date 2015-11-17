//
//  EcomapProblemDetails.h
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapProblem.h"
#import "EcomapLoggedUser.h"
#import "Problem.h"
@interface EcomapProblemDetails : EcomapProblem

@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSString *proposal;
@property (nonatomic, readonly) NSUInteger severity;
@property (nonatomic, readonly) NSUInteger moderation;
@property (nonatomic, readonly) NSUInteger votes;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, readonly) NSUInteger userID;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, readwrite) NSUInteger userCreate;


- (BOOL)canVote:(EcomapLoggedUser *)loggedUser;
- (instancetype)initWithProblemFromCoreData:(Problem*) data;
@end

@protocol EcomapProblemDetailsHolder

- (void)setProblemDetails:(EcomapProblemDetails*)problemDetails;

@end
