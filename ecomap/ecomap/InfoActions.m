//
//  InfoActions.m
//  ecomap
//
//  Created by Vasya on 3/7/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "InfoActions.h"
#import "EcomapUserFetcher.h"
#import "UIViewController+Utils.h"
#import "LoginViewController.h"
#import "LoginWithFacebook.h"
#import "EcomapPathDefine.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@interface InfoActions ()
@property (nonatomic, strong) UIView *activityIndicatorView;
@property (nonatomic, strong) NSMutableArray *popupLabels; //Of UILabels
@property (nonatomic) BOOL userInteraction;
@end

@implementation InfoActions

#pragma mark - Singleton
+ (instancetype)sharedActions
{
    
    static InfoActions *sharedActions = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedActions = [[InfoActions alloc] initPrivate];
    });
    
    return sharedActions;
    
}

-(instancetype)initPrivate
{
    self = [super init];
    if (self)
    {
        self.popupLabels = [[NSMutableArray alloc] init];
        //Add observer to listen when device chages orientation
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(orientationChanged:)
                   name:UIDeviceOrientationDidChangeNotification
                 object:nil];
    }
    
    return self;
}

//Disable init method
-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Error" reason:@"Can't create instanse of this class. To login to server use EcomapUserFetcher class" userInfo:nil];
    return nil;
}

//Center all action views here
- (void)orientationChanged:(NSNotification *)note
{
    CGPoint center = [[UIApplication sharedApplication] keyWindow].center;
    self.activityIndicatorView.center = center;
    [self calculatePopupPosition];
}

#pragma mark - Alets

+ (void)showAlertWithTitile:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Cancel button title on alert")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    
    //Get current ViewControlller
    UIViewController *currentVC = [UIViewController currentViewController];
    
    //Present Alert
    [currentVC presentViewController:alertController animated:YES completion:nil];
}
 
+ (void)showAlertOfError:(id)error
{
    NSString *errorMessage = nil;
    if ([error isKindOfClass:[NSError class]])
    {
        NSError *err = (NSError *)error;
        if (err.code / 100 == 5)
        {
            //5XX error from server
            errorMessage = NSLocalizedString(@"Є проблеми на сервері. Ми працюємо над їх вирішенням!", @"Alert message: There are problems on the server. We are working to resolve them!");
        }
        else if (err.code == NO_INTERNET_CODE)
        {
            errorMessage = NSLocalizedString(@"Не вдається підключитися до Ecomap. Перевірте налаштування мережі Інтернет", @"Alert message: Can't connect to Ecomap. Check your internet connection!");
        }
        else
        {
            errorMessage = [error localizedDescription]; //human-readable dwscription of the error
        }
        
    }
    else if ([error isKindOfClass:[NSString class]])
    {
        errorMessage = (NSString *)error;
    }
    else
    {
        errorMessage = @"";
    }
        
    [self showAlertWithTitile:NSLocalizedString(@"Помилка", @"Error title")
                        andMessage:errorMessage];
}


#pragma mark - Login action sheet
+ (void)showLogitActionSheetFromSender:(id)sender actionAfterSuccseccLogin:(void (^)(void))dismissBlock
{
    
    UIView *senderView = nil;
    if ([sender isKindOfClass:[UIView class]])
    {
        senderView = sender;
    }
    
    //Get current ViewControlller
    UIViewController *currentVC = [UIViewController currentViewController];
    
    //Create UIAlertController with ActionSheet style
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Ця дія потребує авторизації", @"Login actionSheet title: This action requires authorization")
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    //Create UIAlertAction's
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Відмінити", @"Cancel button title on login actionSheet")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       DDLogVerbose(@"Cancel action");;
                                   }];
    
    UIAlertAction *loginAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Вхід", @"Login button title on login actionSheet")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      DDLogVerbose(@"Login button on action sheet pressed");
                                      
                                      //Load LoginViewController from storyboard
                                      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                      UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
                                      
                                      //Get pointer to LoginViewController
                                      LoginViewController *loginVC = (LoginViewController *)[navController topViewController];
                                      
                                      //setup LoginViewController
                                      loginVC.dismissBlock = ^(BOOL isUserActionViewControllerOnScreen){
                                          if (!isUserActionViewControllerOnScreen) {
                                              dismissBlock();
                                          }
                                      };
                                      
                                      //Present modaly LoginViewController
                                      [currentVC presentViewController:navController animated:YES completion:nil];
                                      
                                  }]; //end of UIAlertAction handler block
    
    UIAlertAction *loginWithFacebookAction = [UIAlertAction
                                              actionWithTitle:NSLocalizedString(@"Війти з Facebook", @"Loin with Facebook button title on login actionSheet")
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  DDLogVerbose(@"loginWithFacebook action");
                                                  [LoginWithFacebook loginWithFacebook:^(BOOL result) {
                                                      if (result) {
                                                          //perform dismissBlock
                                                          dismissBlock();
                                                      }

                                                  }]; //end of LoginWithFacebook block
                                                  
                                              }]; //end of UIAlertAction handler block
    
    //add actions to alertController
    [alertController addAction:cancelAction];
    [alertController addAction:loginAction];
    [alertController addAction:loginWithFacebookAction];
    
    //Present ActionSheet
    [currentVC presentViewController:alertController animated:YES completion:nil];
    
    //For iPad popover presentation
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = senderView;
        popover.sourceRect = senderView.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
}

#pragma mark - Popup
#define POPUP_DELAY 1.5
#define POPUP_HEIGHT 50
#define POPUP_WIDTH 170
#define POPUP_VERTICAL_OFFSET 10
+ (void)showPopupWithMesssage:(NSString *)message
{
    if ([message isEqualToString:@""])
    {
        DDLogError(@"Can't show popup with no text");
        return;
    }
    
    InfoActions *sharedActions = [self sharedActions];
    
    //Create popup label
    UILabel *popupLabel = [self createLabelWithText:message];
    [sharedActions.popupLabels addObject:popupLabel];
    
    //Get keyWindos
    UIWindow *appKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    //Set popup position on screen
    [sharedActions calculatePopupPosition];
    
    //show popup
    for (UILabel *popupLabel in sharedActions.popupLabels)
    {
        [appKeyWindow addSubview:popupLabel];
        
        if ([[sharedActions popupLabels] lastObject] == popupLabel)
        {
            popupLabel.transform = CGAffineTransformMakeScale(1.3, 1.3);
            popupLabel.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^{
                popupLabel.alpha = 1;
                popupLabel.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }
        
        
    }
    
    //Dismiss popup after delay
    [self performSelector:@selector(dismissPopup:) withObject:popupLabel afterDelay:POPUP_DELAY];
}

+ (void)dismissPopup:(UIView *)sender
{
    
    InfoActions *sharedActions = [self sharedActions];
    UILabel *label = (UILabel *)sender;
    // Fade out the message and destroy popup
    [UIView animateWithDuration:0.3
                     animations:^  {
                         label.transform = CGAffineTransformMakeScale(1.3, 1.3);
                         label.alpha = 0; }
                     completion:^ (BOOL finished) {
                         [[sharedActions popupLabels] removeObject:label];
                         DDLogVerbose(@"Popup dismissed");
                         [sender removeFromSuperview];
                     }];
}

- (void)calculatePopupPosition
{
    //InfoActions *sharedActions = [self sharedActions];
    
    //Get keyWindos
    UIWindow *appKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    UILabel *firstPopup = [self.popupLabels firstObject];
    CGPoint appWindowCenter = appKeyWindow.center;
    
    //calculate initial vertical offset
    appWindowCenter.y = appKeyWindow.center.y - (POPUP_HEIGHT/2 + POPUP_VERTICAL_OFFSET) * ([[self popupLabels] count] - 1);
    
    //animate offset
    if ([[self popupLabels] count] > 1)
    {
        [UIView animateWithDuration:0.3 animations:^{
            firstPopup.center = appWindowCenter;
        }];
    }
    else
    {
        firstPopup.center = appWindowCenter;
    }
    
    //set vertical offset for other popups
    for (int i = 1; i < [[self popupLabels] count]; i++)
    {
        UILabel *nextPopup = (UILabel *)[[self popupLabels] objectAtIndex:i];
        appWindowCenter.y += POPUP_HEIGHT + POPUP_VERTICAL_OFFSET;
        
        //animate offset
        if ( i != ([[self popupLabels] count] - 1))
        {
            [UIView animateWithDuration:0.3 animations:^{
                nextPopup.center = appWindowCenter;
            }];
        }
        else
        {
           nextPopup.center = appWindowCenter;
        }

    }

}

+ createLabelWithText:(NSString *)message
{
    UILabel *popupLabel = [[UILabel alloc] init];
    //Set text
    popupLabel.text = message;
    
    popupLabel.textAlignment = NSTextAlignmentCenter;
    popupLabel.numberOfLines = 2;
    
    //Set frame
    CGFloat textWidth = popupLabel.intrinsicContentSize.width;
    CGRect labelFrame = CGRectMake(0, 0, textWidth + 20, POPUP_HEIGHT);
    
    //To make popup not to be wider tan 170 points
    if (textWidth > POPUP_WIDTH)
    {
        labelFrame = [popupLabel textRectForBounds:CGRectMake(0, 0, POPUP_WIDTH, POPUP_HEIGHT)
                            limitedToNumberOfLines:2];
    }
    
    popupLabel.frame = labelFrame;
    
    //Set color
    popupLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    popupLabel.textColor = [UIColor whiteColor];
    
    //Make rounded rect
    popupLabel.layer.cornerRadius = 5.0;
    popupLabel.clipsToBounds=YES;
    
    return popupLabel;
}

#pragma mark - Activity Indicator
+ (void)startActivityIndicatorWithUserInteractionEnabled:(BOOL)enabled
{
    
    InfoActions *sharedActions = [self sharedActions];
    
    if (sharedActions.activityIndicatorView)
    {
        DDLogError(@"Can't create 2-nd activity indicator");
        return;
    }
    
    //Get keyWindos
    UIWindow *appKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    sharedActions.userInteraction = enabled;
    if (!enabled)
    {
        //Disable user events handling
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    //Create activity indicator transparent black pad
    sharedActions.activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    sharedActions.activityIndicatorView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    sharedActions.activityIndicatorView.layer.cornerRadius = 5.0;
    sharedActions.activityIndicatorView.clipsToBounds=YES;
    //Position in center
    sharedActions.activityIndicatorView.center = appKeyWindow.center;
    //add to view hierarchy
    [appKeyWindow addSubview:sharedActions.activityIndicatorView];
    
    //Create activity indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator startAnimating];
    activityIndicator.center = CGPointMake(sharedActions.activityIndicatorView.bounds.size.width / 2, sharedActions.activityIndicatorView.bounds.size.height / 2);
    //add to view activityIndicatorPad
    [sharedActions.activityIndicatorView addSubview:activityIndicator];
    
    DDLogVerbose(@"Activity indicator started");
    
    //Show dismiss button after delay (so user can cancel activity indicator in case of some error)
    //[self performSelector:@selector(showDismissButton:) withObject:nil afterDelay:20];
    
}

+ (void)stopActivityIndicator
{
    InfoActions *sharedActions = [self sharedActions];
    
    if (sharedActions.activityIndicatorView)
    {
        [sharedActions.activityIndicatorView removeFromSuperview];
        
        //Enable user events handling
        if (!sharedActions.userInteraction)
        {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
        
        sharedActions.activityIndicatorView = nil;
        
        DDLogVerbose(@"Activity indicator stoped");
    }
}

@end
