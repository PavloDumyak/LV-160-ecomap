//
//  EcomapResources.h
//  ecomap
//
//  Created by Mikhail on 2/4/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapResources : NSObject
@property (nonatomic, strong, readonly) NSString *titleRes; // title of some resource
@property (nonatomic, strong, readonly) NSString *alias;    // alias - path to deatail of resource
@property (nonatomic, readonly) NSUInteger resId;           // id of resource
@property (nonatomic, readonly) NSUInteger IsResource;     // 1 or 0

//Designated initializer
-(instancetype)initWithResource:(NSDictionary *)resource; //init

-(void)parseResources:(NSDictionary *)resource; // pasring
@end
