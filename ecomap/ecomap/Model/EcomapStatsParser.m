//
//  EcomapStatsParser.m
//  ecomap
//
//  Created by ohuratc on 09.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapStatsParser.h"
#import "EcomapPathDefine.h"
#import "EcomapProblem.h"

@implementation EcomapStatsParser

#pragma mark - Parsing Stats For General Stats Top Label

+ (NSUInteger)integerForNumberLabelForInstanceNumber:(NSUInteger)num inGeneralStatsArray:(NSArray *)generalStats
{
    NSUInteger number = 0;
    
    switch(num)
    {
        case 0: number = [[self valueForKey:ECOMAP_GENERAL_STATS_PROBLEMS inGeneralStatsArray:generalStats] integerValue]; break;
        case 1: number = [[self valueForKey:ECOMAP_GENERAL_STATS_VOTES inGeneralStatsArray:generalStats] integerValue]; break;
        case 2: number = [[self valueForKey:ECOMAP_GENERAL_STATS_COMMENTS inGeneralStatsArray:generalStats] integerValue]; break;
        case 3: number = [[self valueForKey:ECOMAP_GENERAL_STATS_PHOTOS inGeneralStatsArray:generalStats] integerValue]; break;
    }
    
    return number;
}

+ (NSString *)stringForNameLabelForInstanceNumber:(NSUInteger)number
{
    NSString *name = @"";
    
    switch(number)
    {
        case 0: name = NSLocalizedString(@"Проблем", @"Problems"); break;
        case 1: name = NSLocalizedString(@"Голосів", @"Votes"); break;
        case 2: name = NSLocalizedString(@"Коментарів", @"Comments"); break;
        case 3: name = NSLocalizedString(@"Фотографій", @"Photos"); break;
    }
    
    return name;
}

// Looking value for key deep inside General Stats Array which contains NSArrays with NSDictionary
+ (id)valueForKey:(NSString *)key inGeneralStatsArray:(NSArray *)generalStats
{
    for(NSArray *arrStats in generalStats)
    {
        // Pop dictionary from array.
        NSDictionary *dictStats = [arrStats firstObject];
        
        // Look for key inside dictionary.
        if([dictStats valueForKey:key])
        {
            // If we found key return value for it.
            return [dictStats valueForKey:key];
        }
        else
        {
            // If didn't continue looking.
            continue;
        }
    }
    
    return nil;
}

#pragma mark - Parsing Stats For "Top Of The Problems" Charts

// Get the paticular "Top Of The Problems" chart from Top Charts Array, depending on its type.
+ (NSArray *)paticularTopChart:(EcomapKindfOfTheProblemsTopList)kindOfChart from:(NSArray *)topCharts
{
    NSArray *topChart = nil;
    
    if(kindOfChart <= [topCharts count])
    {
        topChart = topCharts[kindOfChart];
    }
    
    return topChart;
}

// Get an image to draw in "Top Of The Problems" chart depending on its type.
+ (UIImage *)scoreImageOfProblem:(Problem *)problem forChartType:(EcomapKindfOfTheProblemsTopList)kindOfChart
{
    switch(kindOfChart)
    {
        case EcomapMostCommentedProblemsTopList: return [UIImage imageNamed:@"12"];
        case EcomapMostSevereProblemsTopList: return [UIImage imageNamed:@"16"];
        case EcomapMostVotedProblemsTopList: return [UIImage imageNamed:@"13"];
    }
}

// Get the string with score to draw in "Top Of The Problems" chart depending on its type.
+ (NSString *)scoreOfProblem:(NSDictionary *)problem forChartType:(EcomapKindfOfTheProblemsTopList)kindOfChart
{
    switch(kindOfChart)
    {
        case EcomapMostCommentedProblemsTopList: return [NSString stringWithFormat:@"%@", [problem valueForKey:ECOMAP_PROBLEM_VALUE]];
        case EcomapMostSevereProblemsTopList: return [NSString stringWithFormat:@"%@", [problem valueForKey:ECOMAP_PROBLEM_SEVERITY]];
        case EcomapMostVotedProblemsTopList: return [NSString stringWithFormat:@"%@", [problem valueForKey:ECOMAP_PROBLEM_VOTES]];
    }
}

#pragma mark - Parsing Stats For Pie Chart

+ (UIColor *)colorForProblemType:(NSUInteger)typeID
{
    switch (typeID)
    {
        case 1: return [UIColor colorWithRed:9/255.0 green:91/255.0 blue:15/255.0 alpha:1];
        case 2: return [UIColor colorWithRed:35/255.0 green:31/255.0 blue:32/255.0 alpha:1];
        case 3: return [UIColor colorWithRed:152/255.0 green:68/255.0 blue:43/255.0 alpha:1];
        case 4: return [UIColor colorWithRed:27/255.0 green:154/255.0 blue:214/255.0 alpha:1];
        case 5: return [UIColor colorWithRed:113/255.0 green:191/255.0 blue:68/255.0 alpha:1];
        case 6: return [UIColor colorWithRed:255/255.0 green:171/255.0 blue:9/255.0 alpha:1];
        case 7: return [UIColor colorWithRed:80/255.0 green:9/255.0 blue:91/255.0 alpha:1];
    }
    
    return [UIColor clearColor];
}

@end
