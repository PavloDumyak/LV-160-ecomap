//
//  UIViewController+Utils.h
//  ecomap
//
//  Created by Vasya on 3/7/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Utils)

//Find the current view controller that the user is most likely interacting with
+(UIViewController*) currentViewController;

@end
