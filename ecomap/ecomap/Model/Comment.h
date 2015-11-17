//
//  Comment.h
//  ecomap
//
//  Created by admin on 10/28/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Problem;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * created_by;
@property (nonatomic, retain) NSString * created_date;
@property (nonatomic, retain) NSString * modified_date;
@property (nonatomic, retain) NSNumber * comment_id;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * id_of_problem;
@property (nonatomic, retain) Problem *problem;

@end
