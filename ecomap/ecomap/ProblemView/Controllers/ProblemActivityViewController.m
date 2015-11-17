//
//  ProblemActivityViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/19/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProblemActivityViewController.h"
#import "EcomapActivity.h"

@interface ProblemActivityViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *activityTable;
@property (strong, nonatomic) NSArray *activities;

@end

@implementation ProblemActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityTable.delegate = self;
    self.activityTable.dataSource = self;
}

- (void)setProblemDetails:(EcomapProblemDetails *)problemDetails
{
    NSMutableArray *activities = [NSMutableArray array];
    for (EcomapActivity *comment in problemDetails.comments)
    {
        if (comment.activityTypes_Id != 5)
        {
            [activities addObject:comment];
        }
    }
    self.activities = activities;
    [self.activityTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.activities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    EcomapActivity *comment = [self.activities objectAtIndex:indexPath.row];
    cell.textLabel.text = comment.problemContent;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *detailedText = [NSString stringWithFormat:@"%@ %@ %@",comment.userName, comment.userSurname, [formatter stringFromDate:comment.date]];
    cell.detailTextLabel.text = detailedText;
    
    cell.imageView.image = [self iconForCell:comment.activityTypes_Id];
    return cell;
}

- (UIImage *)iconForCell:(NSUInteger)problemTypeID
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%lu.png", problemTypeID + 10]];
}

@end
