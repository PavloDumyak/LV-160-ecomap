//
//  MapSegue.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "MapSegue.h"
#import "MapViewController.h"
#import "EcomapRevealViewController.h"

@implementation MapSegue

- (void)perform
{
    EcomapRevealViewController *rvc = (EcomapRevealViewController*)[self.sourceViewController revealViewController];
    UINavigationController *dvc = rvc.mapViewController;
    [rvc pushFrontViewController:dvc animated:YES];


}
@end
