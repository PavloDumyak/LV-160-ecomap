//
//  AddCommViewController.m
//  ecomap
//
//  Created by Mikhail on 2/19/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddCommViewController.h"
#import "CommentCell.h"
#import "EcomapFetcher.h"
#import "ContainerViewController.h"
#import "EcomapActivity.h"
#import "EcomapCommentaries.h"
#import "EcomapLoggedUser.h"
#import "EcomapProblemDetails.h"
#import "Defines.h"
#import "EcomapUserFetcher.h"
#import "GlobalLoggerLevel.h"
#import "EcomapUserFetcher.h"
#import "EcomapAdminFetcher.h"
#import "InfoActions.h"
#import "AFNetworking.h"

#import "EcomapFetchedResultController.h"
#import "EcomapCoreDataControlPanel.h"
#import "AppDelegate.h"


@interface AddCommViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, NSFetchedResultsControllerDelegate, EditCommentProtocol>

@property (nonatomic,strong) NSMutableArray* comments;
@property (nonatomic,strong) EcomapProblemDetails * ecoComment;
@property (nonatomic,strong) NSString *problemma;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (nonatomic,strong) UIAlertView *alertView;
@property (nonatomic) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSString* createdComment;

@end

@implementation AddCommViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addCommentButton.enabled = NO;
    
    //Buttons images localozation
    UIImage *addButtonImage = [UIImage imageNamed:NSLocalizedString(@"AddCommentButtonUKR", @"Add comment button image")];
    [self.addCommentButton setImage:addButtonImage forState:UIControlStateNormal];
    
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Editing comment..." message:@"Edit your comment:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [self fetchedResultsController];
    
    [self updateUI];
    
}

- (NSFetchedResultsController *) fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [EcomapFetchedResultController requestForCommentsWithProblemID:self.problem_ID];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    [self.myTableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            [self configureCell:(CommentCell*)[self.myTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

-(void)reload
{
    [self updateUI];
}

-(void)updateUI
{
    self.myTableView.allowsMultipleSelectionDuringEditing = NO;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.estimatedRowHeight = 54.0;
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    self.textField.delegate = self;
    self.textField.text = @"Add comment";
    self.textField.textColor = [UIColor lightGrayColor];
    self.myTableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
    [self.myTableView reloadData];
}

-(void)setProblemDetails:(EcomapProblemDetails *)problemDetails
{
    NSMutableArray *comments = [NSMutableArray array];
    for(EcomapActivity *oneComment in problemDetails.comments )
    {
        if(oneComment.activityTypes_Id ==5)
        {
            [comments addObject:oneComment];
            NSLog(@"(%@, %@ %lu)",oneComment.userName,oneComment.userSurname,(unsigned long)oneComment.usersID);
        }
        self.problemma = [NSString stringWithFormat:@"%lu",(unsigned long)oneComment.problemsID];
    }
    self.comments = comments;
    DDLogVerbose(@"%lu",(unsigned long)self.comments.count);
    [self.myTableView reloadData];
}




- (IBAction)pressAddComment:(id)sender
{
    NSString * fromTextField = self.textField.text;
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
    
    if(userIdent)
    {
        [[NetworkActivityIndicator sharedManager] startActivity];
        
        NSInteger problemID = [self.problem_ID integerValue];
        
        [EcomapFetcher addCommentToProblem:problemID withContent:fromTextField onCompletion:^(NSError *error)
         {
             if (!error)
             {
                 [EcomapFetcher loadEverything];
             }
         }];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NetworkActivityIndicator sharedManager]endActivity];
        });
        
        [InfoActions showPopupWithMesssage:NSLocalizedString(@"Коментар додано", @"Comment is added")];
    }
    
    else
    {
        //show action sheet to login
        [InfoActions showLogitActionSheetFromSender:sender
                           actionAfterSuccseccLogin:^{
                               [self pressAddComment:sender];
                           }];
        return;
    }
    
    if ([self.textField isFirstResponder])
    {
        self.textField.text = @"";
        [self textViewDidEndEditing:self.textField];
    }
}


#pragma  -mark Placeholder

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([self.textField.text isEqualToString:@"Add comment"])
    {
        self.textField.text = @"";
        self.textField.textColor = [UIColor blackColor];
        // self.addCommentButton.enabled = YES;
    }
    [self.textField becomeFirstResponder];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([self.textField.text isEqualToString:@""])
    {
        self.textField.text = @"Add comment";
        self.textField.textColor = [UIColor lightGrayColor];
        self.addCommentButton.enabled = NO;
    }
    
    [self.textField resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.addCommentButton.enabled = [self.textField.text length]>0;
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count == 0 ? 1 : self.fetchedResultsController.fetchedObjects.count;
}


- (void)configureCell:(CommentCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Comment *object = self.fetchedResultsController.fetchedObjects[indexPath.row];
    
    cell.commentContent.text = object.content;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.doesRelativeDateFormatting = YES;
    NSLocale *ukraineLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"uk"];
    [formatter setLocale:ukraineLocale];
    NSString *personalInfo = [NSString stringWithFormat:@"%@", object.created_by];
    NSString *dateInfo = [NSString stringWithFormat:@"%@",object.created_date];
    cell.personInfo.text = personalInfo;
    cell.dateInfo.text = dateInfo;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"Коментарі відсутні";
        return cell;
    }
    else if (indexPath.row < self.fetchedResultsController.fetchedObjects.count)
    {
        Comment *object = self.fetchedResultsController.fetchedObjects[indexPath.row];
        
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.commentContent.text = object.content;
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.doesRelativeDateFormatting = YES;
        NSLocale *ukraineLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"uk"];
        [formatter setLocale:ukraineLocale];
        NSString *personalInfo = [NSString stringWithFormat:@"%@", object.created_by];
        NSString *dateInfo = [NSString stringWithFormat:@"%@",object.created_date]; // or modified date
        cell.personInfo.text = personalInfo;
        cell.dateInfo.text = dateInfo;
        cell.indexPathOfRow = indexPath;
        EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
        
        if(loggedUser && ([loggedUser.name isEqualToString:object.created_by] || [loggedUser.role isEqualToString:@"admin"]))
        {
            cell.editButton.hidden = NO;
        }
        else
        {
            cell.editButton.hidden = YES;
        }
        
        return cell;
    }
    
    return nil;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *content = [self.alertView textFieldAtIndex:0].text;
        Comment *object = self.fetchedResultsController.fetchedObjects[self.currentIndexPath.row];
        
        [EcomapFetcher editComment:[object.comment_id integerValue] withContent:content onCompletion:^(NSError *error)
         {
             if (!error)
             {
                 AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
                 NSManagedObjectContext* context = appDelegate.managedObjectContext;
                 NSFetchRequest *request = [[NSFetchRequest alloc] init];
                 NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment"
                                                           inManagedObjectContext:context];
                 [request setEntity:entity];
                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comment_id == %i", [object.comment_id integerValue]];
                 [request setPredicate:predicate];
                 NSArray *obj = [context executeFetchRequest:request error:nil];
                 Comment *comm = obj[0];
                 [comm setValue:content forKey:@"content"];
                 [context save:nil];

                 [EcomapFetcher updateComments:[object.problem.idProblem integerValue] controller:self];                 
                 [self.myTableView reloadData];
             }
         }];
    }
}

-(void)editComentWithID:(NSIndexPath *)commentIndexPath withContent:(NSString *)content
{
    self.currentIndexPath = commentIndexPath;
    UITextField *textField = [self.alertView textFieldAtIndex:0];
    [textField setText:content];
    [self.alertView show];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.fetchedResultsController.fetchedObjects.count)
    {
        return NO;
    }
    
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
    
    Comment *object = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if([userIdent.name isEqualToString:object.created_by] || [userIdent.role isEqualToString:@"admin"])
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //EcomapCommentaries *ob = [EcomapCommentaries sharedInstance];
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        //NSNumber *num = [[ob.comInfo objectAtIndex:indexPath.row] valueForKey:@"id"];
        Comment *object = self.fetchedResultsController.fetchedObjects[indexPath.row];
        
        [EcomapFetcher deleteComment:[object.comment_id integerValue] onCompletion:^(NSError *error)
         {
             if (!error)
             {
                 AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
                 NSManagedObjectContext* context = appDelegate.managedObjectContext;
                 NSFetchRequest *request = [[NSFetchRequest alloc] init];
                 NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment"
                                                           inManagedObjectContext:context];
                 [request setEntity:entity];
                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comment_id == %i", [object.comment_id integerValue]];
                 [request setPredicate:predicate];
                 NSArray *obj = [context executeFetchRequest:request error:nil];
                 Comment *a = obj[0];
                 NSLog(@"%@",a.content);
                 [context deleteObject:a];
                 [context save:nil];
                 [EcomapFetcher updateComments:[object.problem.idProblem integerValue] controller:self];
                 [UIView transitionWithView:tableView
                                   duration:2
                                    options:UIViewAnimationOptionTransitionCrossDissolve
                                 animations:^(void)
                  {
                      [tableView reloadData];
                  }
                                 completion:nil];
             }
         }];
        
    }
}

@end
