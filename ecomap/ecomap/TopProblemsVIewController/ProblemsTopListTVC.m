//
//  ProblemsTopListTVC.m
//  EcomapStatistics
//
//  Created by ohuratc on 04.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import "ProblemsTopListTVC.h"
#import "EcomapStatsFetcher.h"
#import "EcomapProblemDetails.h"
#import "EcomapStatsParser.h"
#import "EcomapPathDefine.h"
#import "EcomapRevealViewController.h"
#import "AppDelegate.h"
#import "EcomapFetchedResultController.h"

static NSString *const kCellIdentifier = @"Top Problem Cell";

static NSString *const kRequestEntity = @"Problem";
static NSString *const kSortRequestByNumberOfComments = @"numberOfComments";
static NSString *const kSortRequestByNumberOfVotes = @"numberOfVotes";
static NSString *const kSortRequestBySeverity = @"severity";

@interface ProblemsTopListTVC () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *kindOfTopChartSegmentedControl;
@property (nonatomic) EcomapKindfOfTheProblemsTopList kindOfTopChart;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *tableSpinner;

@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ProblemsTopListTVC

@synthesize fetchedResultsController = _fetchedResultsController;


#pragma mark - Initialization

- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSFetchRequest *fetchRequest;
    
    switch (self.kindOfTopChart)
    {
        case 0:
            fetchRequest = [EcomapFetchedResultController requestWithEntityName:kRequestEntity sortBy:kSortRequestByNumberOfVotes limit:10];
            break;
        case 1:
            fetchRequest = [EcomapFetchedResultController requestWithEntityName:kRequestEntity sortBy:kSortRequestBySeverity limit:10];
            break;
        case 2:
            fetchRequest = [EcomapFetchedResultController requestWithEntityName:kRequestEntity sortBy:kSortRequestByNumberOfComments limit:10];
            break;
            
        default:
            break;
    }
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:appDelegate.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:kRequestEntity];
    
    self.fetchedResultsController = theFetchedResultsController;
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // We're starting with hidden table, because we don't have data to populate it
    self.tableView.hidden = YES;
    
    // Set up kind of "Top Of The Problems" chart
    // we want to display and draw it
    [self changeKindOfTopChart:self.kindOfTopChartSegmentedControl];
    
    // Set up reveal button
    [self customSetup];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Problem * problem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *problemTitleLabel = (UILabel *)[cell viewWithTag:100];
    problemTitleLabel.text =  problem.title;
    UILabel *problemScoreLabel = (UILabel *)[cell viewWithTag:101];
    NSString* cont;
    cont =[self scoreOfProblem:problem];
    problemScoreLabel.text = cont;
    UIImageView *problemScoreImageView = (UIImageView *)[cell viewWithTag:102];
    problemScoreImageView.image = [EcomapStatsParser scoreImageOfProblem:problem forChartType:self.kindOfTopChart];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Reload table view to clear all selection
    [self.tableSpinner stopAnimating];
    
    // Show the table
    self.tableView.hidden = NO;
    
    //[self changeChart];
    [self.tableView reloadData];
}

- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if (revealViewController)
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector(revealToggle:)];
        [self.navigationController.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        [self.navigationController.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    }
}

#pragma mark - User Interaction Handlers

- (IBAction)changeKindOfTopChart:(UISegmentedControl *)sender
{
    switch(sender.selectedSegmentIndex)
    {
        case 0:
            self.kindOfTopChart = EcomapMostVotedProblemsTopList;
            self.navigationItem.title = ECOMAP_MOST_VOTED_PROBLEMS_CHART_TITLE;
            _fetchedResultsController = nil;
            break;
        case 1:
            self.kindOfTopChart = EcomapMostSevereProblemsTopList;
            self.navigationItem.title = ECOMAP_MOST_SEVERE_PROBLEMS_CHART_TITLE;
            _fetchedResultsController = nil;
            break;
        case 2:
            self.kindOfTopChart = EcomapMostCommentedProblemsTopList;
            self.navigationItem.title = ECOMAP_MOST_COMMENTED_PROBLEMS_CHART_TITLE;
            _fetchedResultsController = nil;
            break;
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableView Data Source & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    // Display data in the cell
    
    Problem * problem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *problemTitleLabel = (UILabel *)[cell viewWithTag:100];
    problemTitleLabel.text =  problem.title;
    UILabel *problemScoreLabel = (UILabel *)[cell viewWithTag:101];
    NSString* cont;
    cont =[self scoreOfProblem:problem];
    problemScoreLabel.text = cont;
    UIImageView *problemScoreImageView = (UIImageView *)[cell viewWithTag:102];
    problemScoreImageView.image = [EcomapStatsParser scoreImageOfProblem:problem forChartType:self.kindOfTopChart];
    
    return cell;
}

- (NSString*) scoreOfProblem: (Problem*)problem
{
    NSString* scoreOfProblem;
    if (self.kindOfTopChart == EcomapMostVotedProblemsTopList)
    {
        scoreOfProblem = [NSString stringWithFormat:@"%@",problem.numberOfVotes];
    }
    else if (self.kindOfTopChart == EcomapMostSevereProblemsTopList)
    {
        scoreOfProblem = [NSString stringWithFormat:@"%@",problem.severity];
    }
    else if (self.kindOfTopChart == EcomapMostCommentedProblemsTopList)
    {
        scoreOfProblem = [NSString stringWithFormat:@"%lu",(unsigned long)problem.comments.count];
    }
    return scoreOfProblem;
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"Show Problem"])
    {
        if ([segue.destinationViewController isKindOfClass:[ProblemViewController class]])
        {
            ProblemViewController *problemVC = segue.destinationViewController;
            Problem *problem = [self.fetchedResultsController objectAtIndexPath:indexPath];
            problemVC.problemID = [problem.idProblem integerValue];
        }
    }
}

@end
