//
//  Statistics.m
//  ecomap
//
//  Created by Admin on 09.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapStatistics.h"
#import "AppDelegate.h"
@implementation EcomapStatistics

+(instancetype)sharedInstanceStatistics
{
    static EcomapStatistics* singleton;
    static dispatch_once_t token;
    dispatch_once(&token, ^{singleton = [[EcomapStatistics alloc] init];});
    return singleton;
}


- (void)getDataForStatisticsFromCD
{
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Problem"
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    self.allProblemsFromCD = [context executeFetchRequest:request error:nil];
    
}


-(void)statisticsForDay
{
    self.forDay = [[NSMutableArray alloc] initWithCapacity:10];
    NSDate * now = [NSDate date];
    NSInteger arr[7] = {0};
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-1];
    NSDate *new = [gregorian
                   dateByAddingComponents:offsetComponents
                   toDate:now
                   options:0];
    
    for (NSInteger i = 0; i < [self.allProblemsFromCD count]; i++)
    {
        Problem *problemFromCD = self.allProblemsFromCD[i];
        NSComparisonResult result = [new compare: problemFromCD.date];
        if (result == NSOrderedAscending)
        {
            arr[[problemFromCD.problemTypeId integerValue]-1]++;
        }
    }
    
    for( NSInteger i = 0; i<7; i++)
    {
        NSNumber *tmp = [NSNumber numberWithInteger:arr[i]];
        [self.forDay addObject:tmp];
    }
}


-(void)statisticsForWeek
{
    self.forWeek = [[NSMutableArray alloc] initWithCapacity:10];
    NSDate * now = [NSDate date];
    NSInteger arr[7] = {0};
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setWeekOfMonth:-1];
    NSDate *new = [gregorian dateByAddingComponents:offsetComponents
                                             toDate:now
                                            options:0];
    
    for (NSInteger i = 0; i < [self.allProblemsFromCD count]; i++)
    {
        Problem *problemFromCD = self.allProblemsFromCD[i];
        NSComparisonResult result = [new compare: problemFromCD.date];
        if (result == NSOrderedAscending)
        {
            arr[[problemFromCD.problemTypeId integerValue]-1]++;
        }
     }
    
    for ( NSInteger i = 0; i<7; i++)
    {
        NSNumber *tmp = [NSNumber numberWithInteger:arr[i]];
        [self.forWeek addObject:tmp];
    }
}

-(void)statisticsForMonth
{
    self.forMonth = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSDate * now = [NSDate date];
    NSInteger arr[7] = {0};
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:-1];
    NSDate *new = [gregorian dateByAddingComponents:offsetComponents
                                             toDate:now
                                            options:0];
    
    for (NSInteger i = 0; i < [self.allProblemsFromCD count]; i++)
    {
        Problem *problemFromCD = self.allProblemsFromCD[i];
        NSComparisonResult result = [new compare: problemFromCD.date];
        if (result == NSOrderedAscending)
        {
            arr[[problemFromCD.problemTypeId integerValue]-1]++;
        }
    }

    for (NSInteger i = 0; i<7; i++)
    {
        NSNumber *tmp = [NSNumber numberWithInteger:arr[i]];
        [self.forMonth addObject:tmp];
    }
}

-(NSMutableArray*)countAllProblemsCategory
{
    [self getDataForStatisticsFromCD];
    [self statisticsForDay];
    [self statisticsForMonth];
    [self statisticsForWeek];
    self.allProblemsPieChart = [[NSMutableArray alloc] initWithCapacity:10];
    self.countProblems = [self.allProblems count];
   
    for (NSInteger i = 0; i < [self.allProblemsFromCD count]; i++)
    {
        Problem *problemFromCD = self.allProblemsFromCD[i];
        self.countVote+=[problemFromCD.numberOfVotes integerValue];
        self.countComment+=[problemFromCD.numberOfComments integerValue];
    }
    
    self.test = [[NSMutableArray alloc] initWithCapacity:4];
    [self.test addObject:[NSString  stringWithFormat:@"%ld",self.countProblems]];
    [self.test addObject:[NSString  stringWithFormat:@"%ld",self.self.countVote]];
    [self.test addObject:[NSString  stringWithFormat:@"%ld",self.countComment]];
    [self.test addObject:[NSString  stringWithFormat:@"%d",1]];
   
    NSInteger arr[7];
 
    for (NSInteger i = 0; i < 7; i++)
    {
        arr[i] = 0;
    }
    for (NSInteger i = 0; i < [self.allProblemsFromCD count]; i++)
    {
        Problem *problemFromCD = self.allProblemsFromCD[i];
        arr[[problemFromCD.problemTypeId integerValue]-1]++;
    }
    for (NSInteger i = 0; i<7; i++)
    {
        NSNumber *tmp = [NSNumber numberWithInteger:arr[i]];
        [self.allProblemsPieChart addObject:tmp];
    }
    
    return self.allProblemsPieChart;
}

@end
