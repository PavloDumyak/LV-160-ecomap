//
//  LoginWithFacebook.m
//  ecomap
//
//  Created by Vasya on 3/7/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "LoginWithFacebook.h"
#import "EcomapUserFetcher.h"
#import "InfoActions.h"
#import "UserActivityViewController.h"

@interface LoginWithFacebook ()

@end

@implementation LoginWithFacebook

+ (void)loginWithFacebook:(void(^)(BOOL result))complitionHandler
{
    [InfoActions startActivityIndicatorWithUserInteractionEnabled:NO];
    [EcomapUserFetcher loginWithFacebookOnCompletion:^(EcomapLoggedUser *loggedUserFB, NSError *error) {
        [InfoActions stopActivityIndicator];
        BOOL loginResult = NO;
        
        //Handle response
        [self handleResponseToLoginFromFacebookWithError:error
                                                       andLoggedUser:loggedUserFB];
        if (!error && loggedUserFB)
        {
            loginResult = YES;
            //show popup greeting for logged user
            [[[UserActivityViewController alloc] init] showGreetingForUser:loggedUserFB];
        }
        //Call complitionHandler
        complitionHandler(loginResult);
        
    }];  //end of EcomapUserFetchen complition block

}

+ (void)handleResponseToLoginFromFacebookWithError:(NSError *)error andLoggedUser:(EcomapLoggedUser *)user
{
    NSString *faceboolLoginErrorTitle = NSLocalizedString(@"Помилка входу через Facebook", @"Alert title: Error to login with Facebook");
    
    if (!error && !user)
    {
        [InfoActions showAlertWithTitile:faceboolLoginErrorTitle
                              andMessage:NSLocalizedString(@"Неможливо отримати дані для авторизації на Ecomap", @"Alert message: Can't receive user info to login on Ecomap")];
    }
    else if (error.code == 400 )
    {
        [InfoActions showAlertWithTitile:faceboolLoginErrorTitle
                              andMessage:ERROR_MESSAGE_TO_REGISTER];
    }
    else if (error)
    {
        [InfoActions showAlertWithTitile:faceboolLoginErrorTitle
                              andMessage:[error localizedDescription]];
    }
}

@end
