//
//  RegisterViewController.m
//  ecomap
//
//  Created by Gregory Chereda on 2/5/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//


#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "EcomapLoggedUser.h"
#import "EcomapUserFetcher.h"
#import "InfoActions.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"


@implementation RegisterViewController

#pragma mark - text field delegate
//@override
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField)
    {
        [self.surnameTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    }
    else if (textField == self.surnameTextField)
    {
        [self.emailTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    }
    else if (textField == self.emailTextField)
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
        [self registerButton:nil];
    }
    return YES;
}


#pragma mark - buttons


- (IBAction)registerButton:(UIButton *)sender
{
    DDLogVerbose(@"Register on ecomap button pressed");
    NSString *name = self.nameTextField.text;
    NSString *surname = self.surnameTextField.text;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    //Check if all information is ready to be send to Ecomap server
    if (![self canSendRequest])
    {
        return;
    }
    
    [InfoActions startActivityIndicatorWithUserInteractionEnabled:NO];
    //Try to register
    [EcomapUserFetcher registerWithName: name
                            andSurname: surname
                              andEmail: email
                           andPassword: password
                          OnCompletion:^(NSError *error) {
                              
                      //Hadle response
                      [self handleResponseToRegisterWithError:error];
                      if (!error)
                      {
                          
                          //Try to login
                          [EcomapUserFetcher loginWithEmail: email
                                                andPassword: password
                                               OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                                                   
                                                   [InfoActions stopActivityIndicator];
                                                   if (!error && loggedUser)
                                                   {
                                                       //perform dismissBlock before ViewController get off thе screen
                                                       self.dismissBlock(YES);
                                                       [self dismissViewControllerAnimated:YES completion:^{
                                                           //perform dismissBlock after ViewController get off thе screen
                                                           self.dismissBlock(NO);
                                                       }];
                                                       
                                                       //show greeting for logged user
                                                       [self showGreetingForUser:loggedUser];
                                                       
                                                   }
                                                   else
                                                   {
                                                       // In case an error to login has occured
                                                       [InfoActions showAlertOfError:error];
                                                   }
                                               }]; //end of login complition block
                      }
                      else
                      {
                          [InfoActions stopActivityIndicator];
                      }
    }];  //end of registartiom complition block
}

#pragma mark - Helper methods
- (void)handleResponseToRegisterWithError:(NSError *)error
{
    NSString *registerErrorTitle = NSLocalizedString(@"Помилка реєстрації", @"Alert title: Error to Register");
    
    if (error.code == 400)
    {
        [InfoActions showAlertWithTitile:registerErrorTitle
                              andMessage:ERROR_MESSAGE_TO_REGISTER];
        //Change checkmarks image
        [self showCheckmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail]] withImage:CHECKMARK_BAD_IMAGE];
    }
    else if (error)
    {
        [InfoActions showAlertWithTitile:registerErrorTitle
                              andMessage:[error localizedDescription]];
    }
}


@end
