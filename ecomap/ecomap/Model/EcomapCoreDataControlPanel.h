//
//  EcomapCoreDataControlPanel.h
//  ecomap
//
//  Created by Pavlo Dumyak on 19.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Problem.h"
#import "EcomapProblemDetails.h"
#import "MapViewController.h"
#import "Resource.h"
#import "Comment.h"


@class MapViewController;

@interface EcomapCoreDataControlPanel : NSObject

+ (instancetype) sharedInstance;
@property (nonatomic, strong) NSArray *allProblems;
@property (nonatomic, strong) NSArray *descr;
@property (nonatomic, strong) MapViewController *map;
@property (nonatomic, strong) NSString *resourceContent;

- (void) addProblemIntoCoreData;
- (Problem*) returnDetail:(NSInteger)identifier;
- (void) addCommentsIntoCoreData:(NSUInteger)problemID comments:(NSArray*)comments;
- (void) logCommentsFromCoreData;
- (void) addResourceIntoCD:(NSArray*)resources;
- (void) addContentToResource: (NSNumber*) currentID;
@end
