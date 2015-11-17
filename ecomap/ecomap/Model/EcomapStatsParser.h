//
//  EcomapStatsParser.h
//  ecomap
//
//  Created by ohuratc on 09.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EcomapURLFetcher.h"
#import "Problem.h"

// Titles for "Top Of The Problems" charts

#define ECOMAP_MOST_VOTED_PROBLEMS_CHART_TITLE NSLocalizedString(@"ТОП 10 популярних проблем", @"TOP 10 popular problems")
#define ECOMAP_MOST_SEVERE_PROBLEMS_CHART_TITLE NSLocalizedString(@"ТОП 10 важливих проблем", @"TOP 10 important problems")
#define ECOMAP_MOST_COMMENTED_PROBLEMS_CHART_TITLE NSLocalizedString(@"ТОП 10 обговорюваних проблем", @"TOP 10 problems under discussion")

typedef enum
{
    EcomapMostVotedProblemsTopList,
    EcomapMostSevereProblemsTopList,
    EcomapMostCommentedProblemsTopList
} EcomapKindfOfTheProblemsTopList;

@interface EcomapStatsParser : NSObject

+ (NSArray *)paticularTopChart:(EcomapKindfOfTheProblemsTopList)kindOfChart from:(NSArray *)topChart;

+ (NSUInteger)integerForNumberLabelForInstanceNumber:(NSUInteger)num inGeneralStatsArray:(NSArray *)generalStats;

+ (NSString *)stringForNameLabelForInstanceNumber:(NSUInteger)number;

+ (NSString *)scoreOfProblem:(NSDictionary *)problem forChartType:(EcomapKindfOfTheProblemsTopList)kindOfChart;

+ (UIImage *)scoreImageOfProblem:(Problem *)problem forChartType:(EcomapKindfOfTheProblemsTopList)kindOfChart;

+ (UIColor *)colorForProblemType:(NSUInteger)problemTypeID;

@end
