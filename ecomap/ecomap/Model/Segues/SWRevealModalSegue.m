//
//  SWRevealModalSegue.m
//  ecomap
//
//  Created by Vasilii Kotsiuba on 2/19/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "SWRevealModalSegue.h"
#import "SWRevealViewController.h"
#import "MenuViewController.h"
#import "EcomapRevealViewController.h"
#import "UserActivityViewController.h"


@implementation SWRevealModalSegue

- (void)perform
{
    //Get pointer to EcomapRevealViewController
    EcomapRevealViewController *rvc = (EcomapRevealViewController*)[self.sourceViewController revealViewController];
    
    //Get pointer to destination VC
    UINavigationController *dvc = self.destinationViewController;
    
    //Get pointer to UserActionViewController
    id topViewController = [dvc topViewController];
    
    if ([topViewController conformsToProtocol:@protocol(UserAction)])
    {
        id <UserAction> userVC = topViewController;
        
        //Get pointer to mapViewController
        UINavigationController *mapVC = rvc.mapViewController;
        
        userVC.dismissBlock = ^(BOOL isUserActionViewControllerOnScreen){
            if (isUserActionViewControllerOnScreen)
            {
                //Show map
                [rvc setFrontViewController:mapVC];
                //Cloce menu
                [rvc revealToggleAnimated:NO];
            }

        };
    }
    
    //Present viewController modaly
    [rvc presentViewController:dvc animated:YES completion:nil];
}

@end
