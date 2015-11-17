//
//  ProblemFetchResController.h
//  ecomap
//
//  Created by admin on 10/21/15.
//  Copyright © 2015 SoftServe. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface EcomapFetchedResultController : NSFetchedResultsController

+ (NSFetchRequest*)requestWithEntityName:(NSString*)entityName sortBy:(NSString*)sortDescriptor;
+ (NSFetchRequest*)requestWithEntityName:(NSString*)entityName sortBy:(NSString*)sortDescriptor limit:(NSInteger)limitNumber;
+ (NSFetchRequest*)requestForCommentsWithProblemID:(NSNumber*) problemID;

@end
