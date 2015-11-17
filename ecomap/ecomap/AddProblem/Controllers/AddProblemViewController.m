
//
//  AddProblemViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 10.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemViewController.h"
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EcomapFetcher+PostProblem.h"
#import "EcomapProblem.h"
#import "EcomapProblemDetails.h"
#import "InfoActions.h"
#import "EcomapLocalPhoto.h"
#import "MenuViewController.h"
#import "AFNetworking.h"
#import "EcomapRevisionCoreData.h"
#import "EcomapCoreDataControlPanel.h"

@interface AddProblemViewController ()
{
    CGFloat padding;
    CGFloat paddingWithNavigationView;
    CGFloat screenWidth;
}

@property (weak, nonatomic) IBOutlet UIButton *addProblemButton;
@property (nonatomic) UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *goToUkraineButton;
@property (nonatomic) GMSMarker *marker;

@end


@implementation AddProblemViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(orientationChanged:)
         name:UIDeviceOrientationDidChangeNotification
       object:nil];
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    padding = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    [self.propositionLable setHidden:YES];
    [self.gotoNext setHidden:YES];
    [self.view bringSubviewToFront:self.goToUkraineButton];
}


- (void)update:(NSString *)problemName :(NSString*)problemDescription :(NSString*)problemSolution :(GMSMarker*)marker :(NSInteger)typeOfProblem
{
    [self postProblem:problemName
                     :problemDescription
                     :problemSolution
                     :marker
                     :typeOfProblem];
}

- (void)cancel
{
    [self.propositionLable setHidden:YES];
    self.gotoNext.hidden = YES;
    self.addProblemButton.hidden = NO;
    self.propositionLable.hidden = YES;
    self.marker = nil;
    [self.mapView clear];
    [self loadProblems];
}


- (IBAction)showUkrainePlacement:(id)sender
{
   self.mapView.camera = [GMSCameraPosition cameraWithLatitude:50
                                                     longitude:30
                                                          zoom:5];
}

#pragma mark - Buttons

- (IBAction)addProblemButtonTap:(UIButton *)sender
{
    if ([EcomapLoggedUser currentLoggedUser])
    {
        self.propositionLable.hidden = NO;
        self.gotoNext.hidden = NO;
        UIButton *button = sender;
        button.hidden = YES;
        CGRect buttonFrame = button.frame;
        [button setFrame:buttonFrame];
        self.mapView.userInteractionEnabled = YES;
    }
    
    else
    {
        [InfoActions showLogitActionSheetFromSender:sender
                           actionAfterSuccseccLogin:^{
                               [self addProblemButtonTap:sender];
                           }];
    }
}


- (void)closeButtonTap:(id *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"LocateMeDidTap"
                                                  object:nil];
    self.marker.map = nil;
    self.marker = nil;
    [self.addProblemButton setNeedsUpdateConstraints];
    self.mapView.settings.myLocationButton = YES;
    self.addProblemButton.hidden = NO;
    self.navigationItem.rightBarButtonItem = nil;
    [self.addProblemButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
}


- (void)orientationChanged:(id *)sender
{
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    padding = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
}



#define PROBLEM_LOCATION_STRING NSLocalizedString(@"Мiсцезнаходження проблеми", @"Problem location")
#pragma mark - ProblemPost
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
            if (!self.marker && self.addProblemButton.isHidden == YES)
            {
                self.marker = [[GMSMarker alloc] init];
                self.marker.title = PROBLEM_LOCATION_STRING;
                self.marker.map = self.mapView;
                [self setCord:coordinate];
                [self.marker setPosition:coordinate];
            }
              [self setCord:coordinate];
              [self.marker setPosition:self.cord];
}


- (void)postProblem:(NSString *)problemName :(NSString*)problemDescription :(NSString*)problemSolution :(GMSMarker*)marker :(NSInteger)problemType
{
    self.propositionLable.hidden = YES;
    self.addProblemButton.hidden = NO;
    self.marker = nil;
    NSDictionary *params = @{ECOMAP_PROBLEM_TITLE     : problemName,
                             ECOMAP_PROBLEM_CONTENT    : problemDescription,
                             ECOMAP_PROBLEM_PROPOSAL : problemSolution,
                             ECOMAP_PROBLEM_LATITUDE : @(marker.position.latitude),
                             ECOMAP_PROBLEM_LONGITUDE : @(marker.position.longitude),
                             ECOMAP_PROBLEM_ID : @(4),
                             ECOMAP_PROBLEM_TYPE_ID : @(problemType)
                             };
    
    EcomapProblem *problem = [[EcomapProblem alloc] initWithProblem: params];
    EcomapProblemDetails *details = [[EcomapProblemDetails alloc] initWithProblem: params];

    [EcomapFetcher problemPost:problem
                problemDetails:details
                          user:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(NSString *result, NSError *error)
    {
        NSLog(@" ProblemloadCOMPLETE:  %@",error);
        EcomapRevisionCoreData *RevisionObject = [[EcomapRevisionCoreData alloc] init];
                              [RevisionObject checkRevison:nil];
        [self loadProblems];
    }];
}



@end