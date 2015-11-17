//
//  ProfileViewController.m
//  ecomap
//
//  Created by Vasilii Kotsiuba on 2/23/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProfileViewController.h"
#import "EcomapFetcher.h"
#import "EcomapUserFetcher.h"
#import "EcomapLoggedUser.h"
#import "InfoActions.h"
#import "GlobalLoggerLevel.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *surmaneLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation ProfileViewController

#pragma mark - view setup
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareLabels];
}

- (void)prepareLabels
{
    EcomapLoggedUser *user = [EcomapLoggedUser currentLoggedUser];
    self.nameLabel.text = user.name ? user.name : @"";
    self.surmaneLabel.text = user.surname ? user.surname : @"";
    self.roleLabel.text = user.role ? user.role : @"";
    self.emailLabel.text = user.email ? user.email : @"";
}

#pragma mark - Buttons
- (IBAction)closeButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)LogoutButton:(id)sender
{
    DDLogVerbose(@"Logout button pressed");
    [InfoActions startActivityIndicatorWithUserInteractionEnabled:NO];
    [EcomapUserFetcher logoutUser:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(BOOL result, NSError *error) {
        [InfoActions stopActivityIndicator];
        if (!error)
        {
            self.dismissBlock(YES);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            // In case an error to logout has occured
            [InfoActions showAlertOfError:error];
        }
    }];
}

@end
