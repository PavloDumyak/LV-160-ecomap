//
//  LoginWithFacebook.h
//  ecomap
//
//  Created by Vasya on 3/7/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//


//I made this as separate class so I can later use it functionality in action sheet to login with facebook without loading LoginViewController

#import <UIKit/UIKit.h>

@interface LoginWithFacebook : UIViewController

+ (void)loginWithFacebook:(void(^)(BOOL result))complitionHandler;

@end
