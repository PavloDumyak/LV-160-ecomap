//
//  LoginViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "LoginViewController.h"
#import "EcomapLoggedUser.h"
#import "EcomapUserFetcher.h"
#import "RegisterViewController.h"
#import "LoginWithFacebook.h"
#import "InfoActions.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation LoginViewController

#pragma mark - Accessors
//@override (to make allaway visible email and password textField)
-(UITextField *)textFieldToScrollUPWhenKeyboadAppears
{
    return self.passwordTextField;
}

#pragma mark - Text field delegate
//@override
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField)
    {
        [textField resignFirstResponder];
        [self loginButton:nil];
    }
    return YES;
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"register"])
    {
        RegisterViewController *registerVC = segue.destinationViewController;
        registerVC.dismissBlock = self.dismissBlock;
    }
}

#pragma mark - Buttons
- (IBAction)loginButton:(UIButton *)sender
{
    DDLogVerbose(@"Login on ecomap button pressed");
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    //Check if all information is ready to be send to Ecomap server
    if (![self canSendRequest])
    {
        return;
    }
    
    //Change checkmarks image
    [self showCheckmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail], [NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_GOOD_IMAGE];
    
    [InfoActions startActivityIndicatorWithUserInteractionEnabled:NO];
    //Send e-mail and password on server
    [EcomapUserFetcher loginWithEmail:email
                          andPassword:password
                         OnCompletion:^(EcomapLoggedUser *user, NSError *error){
         
         [InfoActions stopActivityIndicator];
         //Handle response
         [self handleResponseToLoginWithError:error andLoggedUser:user];
         if (!error && user)
         {
             
             //perform dismissBlock before ViewController get off thе screen
             self.dismissBlock(YES);
             [self dismissViewControllerAnimated:YES completion:^{
                 //perform dismissBlock after ViewController get off thе screen
                 self.dismissBlock(NO);
             }];
             //show greeting for logged user
             [self showGreetingForUser:user];
         }
         
     }]; //end of login user block
    
}

- (IBAction)loginWithFacebookButton:(id)sender
{
    DDLogVerbose(@"Facebook button pressed");
    [LoginWithFacebook loginWithFacebook:^(BOOL result) {
        if (result)
        {
            //perform dismissBlock before ViewController get off thе screen
            self.dismissBlock(YES);
            [self dismissViewControllerAnimated:YES completion:^{
                //perform dismissBlock after ViewController get off thе screen
                self.dismissBlock(NO);
            }];
        }
    }];
}

- (IBAction)cancelButton:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods
- (void)handleResponseToLoginWithError:(NSError *)error andLoggedUser:(EcomapLoggedUser *)user
{
    NSString *loginErrorTitle = NSLocalizedString(@"Помилка входу", @"Alert title: Error to login");
    
    if (!error && !user)
    {
        [InfoActions showAlertWithTitile:loginErrorTitle
                              andMessage:NSLocalizedString(@"Є проблеми на сервері. Ми працюємо над їх вирішенням!", @"Alert message: There are problems on the server. We are working to resolve them!")];
    }
    else if (error.code == 400 )
    {
        [InfoActions showAlertWithTitile:loginErrorTitle
                              andMessage:NSLocalizedString(@"\nНеправильний пароль або email-адреса", @"Alert message: Incorrect password or email")];
        //Change checkmarks image
        [self showCheckmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail], [NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_BAD_IMAGE];
    }
    else if (error)
    {
        [InfoActions showAlertOfError:error];
    }
}

@end
