//
//  MenuTableViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "MenuViewController.h"
#import "EcomapLoggedUser.h"
#import "SWRevealViewController.h"
#import "EcomapRevealViewController.h"
#import "MapViewController.h"
#import "AddProblemViewController.h"

@implementation SWUITableViewCell

@end
@implementation SWUIUserTableViewCell

@end

@interface MenuViewController () <SWRevealViewControllerDelegate>
@property (nonatomic) BOOL showLogin;
@property (weak,nonatomic) UIViewController *frontViewController;
@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    revealViewController.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (![revealController.frontViewController isKindOfClass:[UINavigationController class]])
    {
        return;
    }
    
    UINavigationController *front = (UINavigationController *)revealController.frontViewController;
    UIViewController *topView = front.topViewController;
    
    if(position == FrontViewPositionRight)
    {
        topView.view.userInteractionEnabled = NO;
    }
    else
    {
        topView.view.userInteractionEnabled = YES;
    }
}

-(BOOL)showLogin
{
    if (![EcomapLoggedUser currentLoggedUser])
    {
        return YES;
    }
    return NO;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
//    // configure the destination view controller:
//    if ( [sender isKindOfClass:[UITableViewCell class]] )
//    {
//        UILabel* c = [(SWUITableViewCell *)sender label];
//        UINavigationController *navController = segue.destinationViewController;
//        ColorViewController* cvc = [navController childViewControllers].firstObject;
//        if ( [cvc isKindOfClass:[ColorViewController class]] )
//        {
//            cvc.color = c.textColor;
//            cvc.text = c.text;
//        }
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    switch ( indexPath.row )
    {
        case 0:
            CellIdentifier = @"map";
            break;
            
        case 1:
            CellIdentifier = @"res";
            break;
            
        case 2:
            CellIdentifier = @"stat";
            break;
            
        case 3:
            CellIdentifier = @"top_chart";
            break;
            
        case 4:
            CellIdentifier = @"about";
            break;
        
        case 5:
            CellIdentifier = self.showLogin ? @"login" : @"logout";
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if ([CellIdentifier isEqualToString:@"logout"])
    {
        EcomapLoggedUser *user = [EcomapLoggedUser currentLoggedUser];
        ((SWUIUserTableViewCell *)cell).userName.text = [NSString stringWithFormat:@"(%@ %@)", user.name, user.surname];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
