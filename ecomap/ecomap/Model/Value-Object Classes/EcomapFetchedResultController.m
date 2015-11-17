//
//  ProblemFetchResController.m
//  ecomap
//
//  Created by admin on 10/21/15.
//  Copyright © 2015 SoftServe. All rights reserved.
//

#import "EcomapFetchedResultController.h"
#import "AppDelegate.h"

@implementation EcomapFetchedResultController

+ (NSFetchRequest*)requestWithEntityName:(NSString*)entityName sortBy:(NSString*)sortDescriptor
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:sortDescriptor ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    
    return fetchRequest;
}

+ (NSFetchRequest*)requestWithEntityName:(NSString*)entityName sortBy:(NSString*)sortDescriptor limit:(NSInteger)limitNumber
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:sortDescriptor ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];    
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setFetchLimit:limitNumber];
    
    return fetchRequest;
}


+ (NSFetchRequest*)requestForCommentsWithProblemID:(NSNumber*) problemID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Comment"
                                   inManagedObjectContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id_of_problem = %@)", problemID];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"created_date" ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    
    return fetchRequest;
}

@end
