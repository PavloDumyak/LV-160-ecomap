//
//  ResourcesViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ResourcesViewController.h"
#import "EcomapRevealViewController.h"
#import "EcomapFetcher.h"
#import "ResourceCell.h"
#import "ResourceDetails.h"
#import "EcomapAlias.h"
#import "EcomapPathDefine.h"
#import "GlobalLoggerLevel.h"
#import "EcomapCoreDataControlPanel.h"
#import "AppDelegate.h"
#import "Resource.h"

static NSString *const kEntityForRequest = @"Resource";
static NSString *const kSortingValue = @"resourceID";

@interface ResourcesViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation ResourcesViewController

- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        [self.navigationController.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    }
}

#pragma mark - TableView
// refreshing method - Spinner refreshing while data loading

- (IBAction)refreshing
{
    [self.refreshControl beginRefreshing];
    [self fetchedResultsController];
    [self.refreshControl endRefreshing];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowDetails"])
    {
        ResourceDetails *detailviewcontroller = [segue destinationViewController];        // Choose the content depending on the number of row in TableView(and as result its find the alias)
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        NSInteger row = [myIndexPath row];
        self.currentPath = self.pathes[row];
        detailviewcontroller.details = self.chosenResource.content;
    }
}

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *request = [EcomapFetchedResultController
                               requestWithEntityName:kEntityForRequest
                               sortBy:kSortingValue];
    
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
    
    [self customSetup];
    [self refreshing];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Resource *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = object.title;
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.chosenResource = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"ShowDetails" sender:indexPath];
}
@end
