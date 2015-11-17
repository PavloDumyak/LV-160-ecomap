//
//  AddProblemViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 10.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "MapViewController.h"
#import "Defines.h"
#import "AddProblemModalController.h"
#import "ProblemFilterTVC.h"
@protocol updateData;
@interface AddProblemViewController : MapViewController<updateData>
@property (weak, nonatomic) IBOutlet UIButton *gotoNext;
@property (weak, nonatomic) IBOutlet UILabel *propositionLable;
@end
