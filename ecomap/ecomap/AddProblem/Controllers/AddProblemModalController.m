//
//  AddProblemModalController.m
//  ecomap
//
//  Created by Admin on 29.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemModalController.h"
#import "AddProblemViewController.h"
@interface AddProblemModalController ()

@end

@implementation AddProblemModalController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentView.delegate = self;
    self.thisMap.userInteractionEnabled = YES;
    [self.view addSubview:self.currentView];
    [self setMap];
    [self.thisMap setDelegate:self];
    [self setMarker];
    self.problemList = ECOMAP_PROBLEM_TYPES_ARRAY;
}


#pragma mark --pickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.problemList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.problemList[row];
}




#pragma mark --map

- (void)setMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.46012686633918
                                                            longitude:30.52173614501953
                                                                 zoom:3];
    self.thisMap = [GMSMapView mapWithFrame:CGRectMake(self.mapView.bounds.origin.x,
                                                       self.mapView.bounds.origin.y,
                                                       self.mapView.bounds.size.width-25,
                                                       self.mapView.bounds.size.height)
                                     camera:camera];
    self.thisMap.myLocationEnabled = YES;
    self.thisMap.settings.myLocationButton = YES;
    self.thisMap.settings.compassButton = YES;
    [self.mapView addSubview:self.thisMap];
}


- (void)setMarker
{
    if (!self.marker)
    {
        self.marker = [[GMSMarker alloc] init];
        self.marker.map = self.thisMap;
    }
    [self.marker setPosition:self.cord];
}


- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (!self.marker)
    {
        self.marker = [[GMSMarker alloc] init];
        self.marker.map = self.thisMap;
    }
    
    [self.marker setPosition:coordinate];
}



- (IBAction)confirm:(id)sender
{
    self.updatedelegate = self.Controller;
    [self.updatedelegate update:self.nameOfProblems.text
              :self.descriptionOfProblem.text
              :self.solvetion.text
              :self.marker
              :[self.pickerProblemView selectedRowInComponent:0]+1];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{  
    self.updatedelegate = self.Controller;
    [self.updatedelegate cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.descriptionOfProblem resignFirstResponder];
    [self.nameOfProblems resignFirstResponder];
    [self.solvetion resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
