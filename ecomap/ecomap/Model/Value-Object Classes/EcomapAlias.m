//
//  EcomapAlias.m
//  ecomap
//
//  Created by Mikhail on 2/6/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapAlias.h"
#import "EcomapPathDefine.h"
@interface EcomapAlias()
@property (nonatomic, strong, readwrite) NSString *content;
@end

@implementation EcomapAlias
-(instancetype)initWithAlias:(NSDictionary *)alias
{
    self = [super init];
    if (self)
    {
        if (!alias)
        {
            return nil;
        }
        [self parseAlias:alias];     //gained string of html
    }
    return self;
}

- (instancetype)init
{
    return nil;
}


#pragma mark - Parsing problem
-(void)parseAlias:(NSDictionary *)alias
{
    if (alias)
    {
        self.content= [self contOfAlias:alias];
    }
}

- (NSString *)contOfAlias:(NSDictionary *)alias
{
    NSString *resourceID = (NSString*)[[alias valueForKey:ECOMAP_RESOURCE_ALIAS_CONTENT] description];
    if (resourceID)
    {
        return resourceID;
    }
    
    return nil;
}




@end
