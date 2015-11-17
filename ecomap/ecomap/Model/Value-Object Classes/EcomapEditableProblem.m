//
//  EcomapEditableProblem.m
//  ecomap
//
//  Created by ohuratc on 02.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapEditableProblem.h"

@interface EcomapEditableProblem()

@end

@implementation EcomapEditableProblem

#pragma mark - Initializers

// Designated initializer
- (instancetype)initWithProblem:(EcomapProblemDetails *)problem
{
    self = [super init];
    
    if(self)
    {
        self.content = problem.content;
        self.solved = problem.isSolved;
        self.proposal = problem.proposal;
        self.severity = problem.severity;
        self.title = problem.title;
    }
    
    return self;
}

// Overridden initializer
- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.content = @"";
        self.solved = NO;
        self.proposal = @"";
        self.severity = 0;
        self.title = @"";
    }
    
    return self;
}

@end
