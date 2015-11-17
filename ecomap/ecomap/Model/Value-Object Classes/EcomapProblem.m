//
//  EcomapProblem.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapProblem.h"
#import "EcomapPathDefine.h"
#import "EcomapLoggedUser.h"
#import "AppDelegate.h"
#import "EcomapFetchedResultController.h"


@interface EcomapProblem ()
@property (nonatomic, readwrite) NSUInteger problemID;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, readwrite) double latitude;
@property (nonatomic, readwrite) double longitude;
@property (nonatomic, readwrite) NSUInteger problemTypesID;
@property (nonatomic, strong, readwrite) NSString *problemTypeTitle;
@property (nonatomic, readwrite) BOOL isSolved;
@property (nonatomic, strong, readwrite) NSDate *dateCreated;
@property (nonatomic, readwrite) NSUInteger userCreator;
@property (nonatomic, readwrite) NSUInteger vote;
@property (nonatomic, readwrite) NSUInteger severity;
@property (nonatomic, readwrite) NSUInteger numberOfComments;
@end

@implementation EcomapProblem

-(instancetype)initWithProblemFromCoreData:(Problem*)data
{
    self = [super init];
    
    if (self)
    {
        self.problemID = [data.idProblem integerValue];
        self.title = data.title;
        self.latitude = [data.latitude floatValue];
        self.longitude = [data.longitude floatValue];
        self.problemTypesID = [data.problemTypeId integerValue];
        self.dateCreated = data.date;
        long int typeOfProblem = [data.problemTypeId integerValue];
        
        if(typeOfProblem == 0)
        {
            typeOfProblem = 1;
        }
        else
        {
            typeOfProblem -= 1;
        }
        
        self.problemTypeTitle = [ECOMAP_PROBLEM_TYPES_ARRAY objectAtIndex:typeOfProblem];
        self.userCreator = [data.userID integerValue];
        self.vote = [data.numberOfVotes integerValue];
        self.severity = [data.severity integerValue];
        self.numberOfComments = [data.numberOfComments integerValue];
        self.isSolved = data.status;
    }
   return self;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
   
    [coder encodeInteger:self.problemID forKey:@"problemID"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeDouble:self.latitude forKey:@"latitude"];
    [coder encodeDouble:self.longitude forKey:@"longitude"];
    [coder encodeInteger:self.problemTypesID forKey:@"problemTypesID"];
    [coder encodeObject:self.problemTypeTitle forKey:@"problemTypeTitle"];
    [coder encodeBool:self.isSolved forKey:@"isSolved"];
    [coder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [coder encodeInteger:self.userCreator forKey:@"userCreated"];
    [coder encodeInteger:self.userCreator forKey:@"vote"];
    [coder encodeInteger:self.userCreator forKey:@"severity"];
    [coder encodeInteger:self.userCreator forKey:@"numberOfComments"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self.problemID =[coder decodeIntegerForKey:@"problemID"];
    self.title = [coder decodeObjectForKey:@"title"];
    self.latitude = [coder decodeDoubleForKey:@"latitude"];
    self.longitude = [coder decodeDoubleForKey:@"longtitude"];
    self.problemTypesID = [coder decodeIntegerForKey:@"problemTypesID"];
    self.problemTypeTitle = [coder decodeObjectForKey:@"problemTypeTitle"];
    self.isSolved = [coder decodeBoolForKey:@"isSolved"];
    self.dateCreated = [coder decodeObjectForKey:@"dateCreated"];
    self.userCreator = [coder decodeIntegerForKey:@"userCreated"];
    self.vote = [coder decodeIntegerForKey:@"vote"];
    self.severity = [coder decodeIntegerForKey:@"severity"];
    self.numberOfComments = [coder decodeIntegerForKey:@"numberOfComments"];
    return self;
}


#pragma mark - Designated initializer
-(instancetype)initWithProblem:(NSDictionary *)problem
{
    self = [super init];

    if (self)
    {
        if (!problem) return nil;
        self.problemID = ![[problem valueForKey:ECOMAP_PROBLEM_ID] isKindOfClass:[NSNull class]] ? [[problem valueForKey:ECOMAP_PROBLEM_ID] integerValue] : 0;
        self.title = ![[problem valueForKey:ECOMAP_PROBLEM_TITLE] isKindOfClass:[NSNull class]] ? [problem valueForKey:ECOMAP_PROBLEM_TITLE] : nil;
        self.latitude = ![[problem valueForKey:ECOMAP_PROBLEM_LATITUDE] isKindOfClass:[NSNull class]] ? [[problem valueForKey:ECOMAP_PROBLEM_LATITUDE] doubleValue] : 0;
        self.longitude = ![[problem valueForKey:ECOMAP_PROBLEM_LONGITUDE] isKindOfClass:[NSNull class]] ? [[problem valueForKey:ECOMAP_PROBLEM_LONGITUDE] doubleValue] : 0;
        self.problemTypesID = ![[problem valueForKey:ECOMAP_PROBLEM_TYPE_ID] isKindOfClass:[NSNull class]] ? [[problem valueForKey:ECOMAP_PROBLEM_TYPE_ID] integerValue] : 0;
        self.problemTypeTitle = [ECOMAP_PROBLEM_TYPES_ARRAY objectAtIndex:(self.problemTypesID - 1)];
        NSString *isSolvedStr = ![[problem valueForKey:ECOMAP_PROBLEM_STATUS] isKindOfClass:[NSNull class]] ? [problem valueForKey:ECOMAP_PROBLEM_STATUS]  : @"";
        self.isSolved = [isSolvedStr isEqualToString:@"UNSOLVED"] ? NO : YES;
        //self.dateCreated = [self datetime:problem];
        NSString * stringWithDate =[problem valueForKey:@"datetime"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateCreatedOfProblem = [dateFormatter dateFromString:stringWithDate];
        self.dateCreated = dateCreatedOfProblem;
        //Adding userID
        self.userCreator = ![[problem valueForKey:@"user_id"] isKindOfClass:[NSNull class]] ? [[problem valueForKey:@"user_id"] integerValue] : 0;
        self.vote = ![[problem valueForKey:@"number_of_votes"] isKindOfClass:[NSNull class]] ? [[problem valueForKey:@"number_of_votes"] integerValue] : 0;
        self.numberOfComments = ![[problem valueForKey:@"number_of_comments"] isKindOfClass:[NSNull class]] ? [[problem valueForKey:@"number_of_comments"] integerValue] : 0;
        self.severity =![[problem valueForKey:@"severity"] isKindOfClass:[NSNull class]] ? [[problem valueForKey:@"severity"] integerValue] : 0;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Error" reason:@"Use designated initializer -initWithProblem:" userInfo:nil];
    return nil;
}

//Returns problem's date added
- (NSDate *)dateCreatedOfProblem:(NSDictionary *)problem
{
    NSDate *date = nil;
    NSString *dateString = [problem valueForKey:ECOMAP_PROBLEM_DATE];
    if (dateString)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
        date = [dateFormatter dateFromString:dateString];
        if (date) return date;
    }
    
    return nil;
}



@end
