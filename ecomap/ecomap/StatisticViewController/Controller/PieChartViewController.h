//
//  PieChartViewController.h
//  EcomapStatistics
//
//  Created by ohuratc on 03.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"

#import "EcomapStatistics.h"
@interface PieChartViewController : UIViewController <XYPieChartDelegate, XYPieChartDataSource>

@property (strong, nonatomic) NSArray *statsForPieChart;
@property (strong, nonatomic) NSArray *generalStats;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChartView;

@end
