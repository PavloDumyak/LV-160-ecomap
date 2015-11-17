//
//  AddProblemModalController.h
//  ecomap
//
//  Created by Admin on 29.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GClusterManager.h"
#import "SRWebSocket.h"
#import "ProblemViewController.h"
#import "EcomapRevisionCoreData.h"
#import "EcomapCoreDataControlPanel.h"
#import "AddProblemViewController.h"
@protocol updateData <NSObject>

- (void)update :(NSString*)problemName :(NSString*)problemDescription :(NSString*)problemSolution :(GMSMarker*)marker :(NSInteger)typeOfProblem;
- (void)cancel;
@end


@interface AddProblemModalController : UIViewController<UIScrollViewDelegate,GMSMapViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic)NSObject <updateData>* updatedelegate;
@property (nonatomic, strong) AddProblemViewController *Controller;
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView *currentView;
@property (weak, nonatomic) IBOutlet UITextView *nameOfProblems;
@property (weak, nonatomic) IBOutlet UITextView *descriptionOfProblem;
@property (weak, nonatomic) IBOutlet UITextView *solvetion;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerProblemView;
@property (nonatomic, strong) GMSMapView *thisMap;
@property (nonatomic, strong) GMSMarker *marker;
@property (nonatomic)CLLocationCoordinate2D cord;
@property (nonatomic, strong) NSArray *problemList;
- (IBAction)confirm:(id)sender;
- (IBAction)cancel:(id)sender;
@end
