//
//  EcomapResources.m
//  ecomap
//
//  Created by Mikhail on 2/4/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapResources.h"
#import "EcomapPathDefine.h"

@interface EcomapResources()

@property (nonatomic, strong, readwrite) NSString *titleRes;
@property (nonatomic, strong, readwrite) NSString *alias;
@property (nonatomic, readwrite) NSUInteger resId;
@property (nonatomic, readwrite) NSUInteger IsResource;

@end

@implementation EcomapResources

#pragma mark - Designated initializer
-(instancetype)initWithResource:(NSDictionary *)resource
{
    self = [super init];
    if (self)
    {
        if (!resource)
        {
            return nil;
        }
        [self parseResources:resource];
    }
    return self;
}

- (instancetype)init
{
    return nil;
}

#pragma mark - Parsing problem
-(void)parseResources:(NSDictionary *)resource
{
    if (resource)
    {
        self.titleRes = [self titleOfRes:resource];
        self.alias = [self titleOfAlias:resource];
        self.IsResource = [self IsRes:resource];
        self.resId = [self IDOfResource:resource];
    }
}

- (NSString *)titleOfRes:(NSDictionary *)resource
{
    NSString *titleRes = (NSString*)[resource valueForKey:ECOMAP_RESOURCE_TITLE];
    if (titleRes) {
        return titleRes;
    }
    return nil;
}


- (NSString *)titleOfAlias:(NSDictionary *)resource
{
    NSString *titleAlias = (NSString *)[resource valueForKey:ECOMAP_RESOURCE_ALIAS];
    if (titleAlias)
    {
        return titleAlias;
    }
    return nil;
}

- (NSUInteger)IDOfResource:(NSDictionary *)resource
{
    NSUInteger resourceID = [[resource valueForKey:ECOMAP_RESOURCE_ID] integerValue];
    if (resourceID)
    {
        return resourceID;
    }
    return NSNotFound;
}

- (NSUInteger)IsRes:(NSDictionary *)resource
{
    NSUInteger resIs = [[resource valueForKey:ECOMAP_RESOURCE_ISRESOURCE] integerValue];
    if (resIs)
    {
        return resIs;
    }
    return NSNotFound;
}




@end
