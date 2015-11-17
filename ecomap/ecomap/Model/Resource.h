//
//  Resource.h
//  ecomap
//
//  Created by admin on 10/27/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Resource : NSManagedObject

@property (nonatomic, retain) NSString * alias;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * resourceID;
@property (nonatomic, retain) NSString * title;

@end
