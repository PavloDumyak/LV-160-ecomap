//
//  ContainerViewController.h
//  ecomap
//
//  Created by Inna Labuskaya on 2/18/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EcomapProblemDetails.h"

@interface ContainerViewController : UIViewController <EcomapProblemDetailsHolder>
- (void)showViewAtIndex:(NSUInteger)index;
@property (strong, nonatomic) NSNumber *problem_id;
@end
