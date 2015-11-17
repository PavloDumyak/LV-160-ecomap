//
//  ProblemFilterTVC.h
//  ecomap
//
//  Created by ohuratc on 05.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
///

#import <UIKit/UIKit.h>

@class EcomapProblemFilteringMask;

// Declare delegate protocol.

@protocol ProblemFilterTVCDelegate <NSObject>

- (void)userDidApplyFilteringMask:(EcomapProblemFilteringMask *)filteringMask;

@end

@interface ProblemFilterTVC : UITableViewController

@property (strong, nonatomic) EcomapProblemFilteringMask *filteringMask;
@property (strong, nonatomic) id <ProblemFilterTVCDelegate> delegate;

@end
