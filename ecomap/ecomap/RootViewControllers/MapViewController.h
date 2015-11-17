//
//  ViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
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
//#import "AddProblemViewController.h"

@class AddProblemViewController;

@interface MapViewController : UIViewController <GMSMapViewDelegate, SRWebSocketDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic)CLLocationCoordinate2D cord;
@property (nonatomic, strong) AddProblemViewController *problemController;

- (void)loadProblems;
- (void)mapSetup;

@end

