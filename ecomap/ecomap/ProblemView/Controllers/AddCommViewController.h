//
//  AddCommViewController.h
//  ecomap
//
//  Created by Mikhail on 2/19/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EcomapProblem.h"
#import "EcomapProblemDetails.h"




@interface AddCommViewController : UIViewController <EcomapProblemDetailsHolder>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (strong, nonatomic) NSNumber* problem_ID;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


-(void)reload;

@end

