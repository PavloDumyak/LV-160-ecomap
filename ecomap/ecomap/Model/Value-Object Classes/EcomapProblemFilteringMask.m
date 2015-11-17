//
//  EcomapProblemFilteringMask.m
//  ecomap
//
//  Created by ohuratc on 19.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapProblemFilteringMask.h"
#import "EcomapPathDefine.h"
#import "EcomapProblem.h"
#import "EcomapLoggedUser.h"

@implementation EcomapProblemFilteringMask

#pragma mark - Properties

// Check wether Problem type array consists type ID.
// If not add it, in other case remove it from array.
- (void)markProblemType:(NSInteger)problemTypeID
{
    if ([self.problemTypes containsObject:@(problemTypeID)])
    {
        [self.problemTypes removeObject:@(problemTypeID)];
    }
    else
    {
        [self.problemTypes addObject:@(problemTypeID)];
    }
}

+ (NSArray *)validProblemTypeIDs
{
    return @[@1, @2, @3, @4, @5, @6, @7];
}

#pragma mark - Overridden Methods

- (instancetype)init
{
    self = [super init];
    
    // By default set mask so it could permit any problem.
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.fromDate = [dateFormatter dateFromString:@"2014-02-18"];
    self.toDate = [NSDate date];
    self.problemTypes = [[EcomapProblemFilteringMask validProblemTypeIDs] mutableCopy];
    self.showSolved = YES;
    self.showUnsolved = YES;
    
    return self;
}


// To ease logging override description.
- (NSString *)description
{
    NSLog(@"Start date: %@", self.fromDate);
    NSLog(@"End date: %@", self.toDate);
    NSLog(@"Problem types: %@", self.problemTypes);
    NSLog(@"Show solved: %@", self.showSolved ? @"YES" : @"NO");
    return [NSString stringWithFormat:@"Show unsolved: %@", self.showUnsolved ? @"YES" : @"NO"];
}

#pragma mark - Applying Filter

// Apply filtering mask (itself) on problems array and return filtered array.
- (NSArray *)applyOnArray:(NSArray *)problems
{
    NSMutableArray *filteredProblems = [[NSMutableArray alloc] init];
    
    for (id problem in problems)
    {
        if ([problem isKindOfClass:[EcomapProblem class]])
        {
            EcomapProblem *ecoProblem = (EcomapProblem *)problem;
            if ([self checkProblem:ecoProblem])
            {
                [filteredProblems addObject:ecoProblem];
            }
        }
    }
    
    return filteredProblems;
}


// Check problem validity.
- (BOOL)checkProblem:(EcomapProblem *)problem
{
    if ([self.problemTypes containsObject:[NSNumber numberWithInteger:problem.problemTypesID]])
    {
        if ([self isDate:problem.dateCreated inRangeFromDate:self.fromDate toDate:self.toDate])
        {
            if ([self checkStatusOfProblem:problem])
            {
                if ([self isOwner:problem])
                {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

// Check problem status validity.
- (BOOL)checkStatusOfProblem:(EcomapProblem *)problem
{
    if (self.showSolved && self.showUnsolved)
    {
        return YES;
    }
    else if (self.showSolved && !self.showUnsolved && problem.isSolved)
    {
        return YES;
    }
    else if (!self.showSolved && self.showUnsolved && !problem.isSolved)
    {
        return YES;
    }
    
    return NO;
}

// Check problem date of creation on validity.
- (BOOL)isDate:(NSDate *)date inRangeFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSTimeInterval intervalFromBeginOfTheRangeToDate = [date timeIntervalSinceDate:fromDate];
    NSTimeInterval intervalFromDateToEndOfTheRange = [toDate timeIntervalSinceDate:date];
    
    if ((intervalFromBeginOfTheRangeToDate > 0) && intervalFromDateToEndOfTheRange > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//Check problem owner
- (BOOL)isOwner:(EcomapProblem *)problem
{
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
    if (!self.showCurrentUserProblem)
    {
        return YES;
    }
    else if (self.showCurrentUserProblem && problem.userCreator == userIdent.userID)
    {
        return YES;
    }
    return NO;
}

@end
