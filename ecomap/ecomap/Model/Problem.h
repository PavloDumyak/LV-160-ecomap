//
//  Problem.h
//  ecomap
//
//  Created by admin on 10/28/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment;

@interface Problem : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * idProblem;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * numberOfComments;
@property (nonatomic, retain) NSNumber * numberOfVotes;
@property (nonatomic, retain) NSNumber * problemTypeId;
@property (nonatomic, retain) NSString * proposal;
@property (nonatomic, retain) NSNumber * severity;
@property (nonatomic, assign) bool status;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSSet *comments;
@end

@interface Problem (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
