//
//  ChangePasswordViewController.m
//  ecomap
//
//  Created by Vasya on 3/2/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "EcomapLoggedUser.h"
#import "EcomapUserFetcher.h"
#import "InfoActions.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation ChangePasswordViewController
#pragma mark - text field delegate
//@override
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.oldPasswordTextField)
    {
        [self.passwordTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    }
    else if (textField == self.passwordTextField)
    {
        [self.confirmPasswordTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    }
    else if (textField == self.confirmPasswordTextField)
    {
        [textField resignFirstResponder];
        [self changePassworButton:nil];
    }
    return YES;
}


#pragma mark - buttons

- (IBAction)changePassworButton:(UIButton *)sender
{
    DDLogVerbose(@"Change password button pressed");
    NSString *oldPasswod = self.oldPasswordTextField.text;
    NSString *password = self.passwordTextField.text;
    
    //Check if all information is ready to be send to Ecomap server
    if (![self canSendRequest])
    {
        return;
    }
    
    [InfoActions startActivityIndicatorWithUserInteractionEnabled:NO];
    //Try to change password
    [EcomapUserFetcher changePassword:oldPasswod
                        toNewPassword:password
                         OnCompletion:^(NSError *error) {
                             [InfoActions stopActivityIndicator];
                             if (!error)
                             {
                                 [self.navigationController popViewControllerAnimated:YES];
                                 [InfoActions showPopupWithMesssage:NSLocalizedString(@"Ваш пароль змінено", @"Password changed") ];
                             }
                             else if (error.code == 400)
                             {
                                 //Change checkmarks image
                                 [self showCheckmarks:@[[NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_BAD_IMAGE];
                                 [InfoActions showAlertOfError:NSLocalizedString(@"\nВи ввели невірний пароль", @"Your password is incorrect")];
                             }
                             else
                             {
                                 [InfoActions showAlertOfError:error];
                             }
                             
                         }]; //end of change password block
}

@end
