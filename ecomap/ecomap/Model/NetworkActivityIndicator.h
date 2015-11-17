//
//  NetworkActivityIndicator.h
//  ecomap
//
//  Created by Mikhail on 2/11/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkActivityIndicator : NSObject
//Get class singleton
+(NetworkActivityIndicator *)sharedManager;

//Show network activity indicator
-(void)startActivity;

-(void)endActivity;

-(void)allActivitiesComplete;

@end
