//
//  Statistics.h
//  ecomap
//
//  Created by Admin on 09.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcomapProblem.h"
@interface EcomapStatistics : NSObject
+(instancetype)sharedInstanceStatistics;
-(NSMutableArray*)countAllProblemsCategory;

-(void)statisticsForMonth;
-(void)statisticsForDay;
-(void)statisticsForWeek;

@property (nonatomic, strong)NSArray *allProblemsFromCD;

@property (nonatomic) NSMutableArray* allProblemsPieChart;
@property (nonatomic, strong) NSArray* allProblems;
@property (nonatomic, assign) NSInteger countProblems;
@property (nonatomic, assign) NSInteger countVote;
@property (nonatomic, assign) NSInteger countComment;
@property (nonatomic, assign) NSInteger countPhotos;
@property (nonatomic, weak)   EcomapProblem* currentProblem;
@property (nonatomic) NSMutableArray *test;
@property (nonatomic) NSMutableArray *forDay;
@property (nonatomic) NSMutableArray *forWeek;
@property (nonatomic) NSMutableArray *forMonth;
@end
