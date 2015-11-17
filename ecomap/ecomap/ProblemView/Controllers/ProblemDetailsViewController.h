//
//  ProblemDetailsViewController.h
//  ecomap
//
//  Created by Inna Labuskaya on 2/18/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EcomapProblemDetails.h"

@interface ProblemDetailsViewController : UIViewController <EcomapProblemDetailsHolder>

@property (nonatomic, strong) EcomapProblemDetails* problemDetails;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;


@end
