//
//  EcomapRevisionCoreData.h
//  ecomap
//
//  Created by Pavlo Dumyak on 10/20/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckRevisionProtocol.h"

@protocol LoadedDifferencesProtocol <NSObject>

- (void)showDetailView;

@end

@interface EcomapRevisionCoreData : NSObject

+ (instancetype)sharedInstance;
- (void)loadDifferance;
- (void)checkRevison:(id)classType;
- (void)actionFetcher:(id)classType;

@property (nonatomic, weak) NSObject <CheckRevisionProtocol> *delegate;
@property (nonatomic, strong) NSArray *allRevisions;
@property (nonatomic, strong) NSArray *allActions;
@property (nonatomic, weak) NSObject <LoadedDifferencesProtocol> *loadDelegate;

@end



