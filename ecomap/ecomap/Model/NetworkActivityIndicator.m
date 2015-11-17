//
//  NetworkActivityIndicator.m
//  ecomap
//
//  Created by Mikhail on 2/11/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "NetworkActivityIndicator.h"
#import "AppDelegate.h"

@interface NetworkActivityIndicator()
@property (nonatomic) NSInteger tasks;
@property (strong,nonatomic) UIApplication *application;
@end
@implementation NetworkActivityIndicator

+(NetworkActivityIndicator *)sharedManager
{
    static NetworkActivityIndicator *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        sharedInstance = [[self alloc]init];
    });
    
    return sharedInstance;
}

-(void)startActivity
{    //DDLogVerbose(@"%ld",(long)self.tasks);
    @synchronized(self)
    {
        if (self.application.isStatusBarHidden)
        {
            return;
        }
        if (!self.application.isNetworkActivityIndicatorVisible)
        {
            self.application.networkActivityIndicatorVisible = YES;
            self.tasks = 0;
        }
        self.tasks++;
    }
}

-(void)endActivity
{  //DDLogVerbose(@"%ld",(long)self.tasks);
    @synchronized(self)
    {
        if (self.application.isStatusBarHidden)
        {
            return;
        }
        self.tasks--;
        if (self.tasks <=0)
        {
            self.application.networkActivityIndicatorVisible = NO;
            self.tasks = 0;
        }
    }
}

-(void)allActivitiesComplete
{
    @synchronized(self)
    {
        if (self.application.isStatusBarHidden)
        {
            return;
        }
        self.application.networkActivityIndicatorVisible = NO;
        self.tasks = 0;
    }
}

-(UIApplication*)application
{
    if (!_application)
    {
        _application = [UIApplication sharedApplication];
    }
    return _application;
}

-(NetworkActivityIndicator*)init
{
    self = [super init];
    self.tasks = 0;
    return self;
}
@end
