//
//  ResourcesViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resource.h"

#import "ResourceTableViewController.h"
#import "EcomapFetchedResultController.h"


@interface ResourcesViewController : ResourceTableViewController

@property (nonatomic,strong) NSMutableArray *titleRes;   // titles of resources
@property (nonatomic,strong) NSString *descriptionRes;    // description in html format from EcomapAlias Parser
@property (nonatomic,strong) NSArray *pathes;           // array of aliases [about/ cleaning..]
@property (nonatomic, strong) NSString *currentPath;  // current allias

@property (nonatomic, weak) Resource * chosenResource;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
