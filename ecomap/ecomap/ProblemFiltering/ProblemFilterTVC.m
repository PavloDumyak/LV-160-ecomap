//
//  ProblemFilterTVC.m
//  ecomap
//
//  Created by ohuratc on 05.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProblemFilterTVC.h"
#import "EcomapPathDefine.h"
#import "EcomapProblemFilteringMask.h"

static NSInteger numberOfSections = 3;

static float standardRowHeight = 44.0;
static float datePickerRowHeight = 164;

static int kDatePickerTag = 101;
static int kProblemTypeImageTag = 102;
static int kTitleTag = 103;
static int kCheckmarkImageTag = 104;

static NSString *kDateCellID = @"dateCell";
static NSString *kProblemTypeCellID = @"problemTypeCell";
static NSString *kProblemStatusCellID = @"problemStatusCell";
static NSString *kDatePickerCellID = @"datePickerCell";

@interface ProblemFilterTVC ()

@property (strong, nonatomic) EcomapProblemFilteringMask *filteringMask;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;
@property (assign) NSInteger pickerCellRowHeight;

@end

@implementation ProblemFilterTVC

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self createDateFormatter];
    
    NSLog(@"View load successfully");
    NSLog(@"Start date: %@", self.filteringMask.fromDate);
    NSLog(@"End date: %@", self.filteringMask.toDate);
}

#pragma mark - Properties

- (EcomapProblemFilteringMask *)filteringMask
{
    if(!_filteringMask) _filteringMask = [[EcomapProblemFilteringMask alloc] init];
    return _filteringMask;
}

#pragma mark - Helper Methods

- (void)createDateFormatter
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
}

- (BOOL)datePickerIsShown
{
    return self.datePickerIndexPath != nil;
}

// Helper method using to capitalize only the first letter in the string.
- (NSString *)uppercaseFirstLetter:(NSString *)string
{
    NSString *firstLetter = [string substringToIndex:1];
    return [[firstLetter uppercaseString] stringByAppendingString:[string substringFromIndex:1]];
}

// Choose image for displaying checkmark
- (UIImage *)checkmarkImage:(BOOL)isCheckmarkSet
{
    return isCheckmarkSet ? [UIImage imageNamed:@"Good"] : nil;
}

- (NSDate *)dateFromIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *parentCellIndexPath = indexPath;
    
    if([self datePickerIsShown]) {
        parentCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    }
    
    return (parentCellIndexPath.row == 0) ? self.filteringMask.fromDate : self.filteringMask.toDate;
}

- (void)setDate:(NSDate *)date forIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        self.filteringMask.fromDate = date;
    } else {
        self.filteringMask.toDate = date;
    }
}

- (UITableViewCell *)createDateCellForIndexPath:(NSIndexPath *)indexPath
{
    // Create cell from template
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDateCellID];
    
    // Configure cell data
    cell.textLabel.text = (indexPath.row == 0) ? @"Показати з:" : @"Показати до:";
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[self dateFromIndexPath:indexPath]];
    return cell;
}

- (UITableViewCell *)createProblemTypeCellForIndexPath:(NSIndexPath *)indexPath
{
    // Create cell from template
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProblemTypeCellID];
    
    // Configure cell image.
    UIImageView *problemTypeImageView = (UIImageView *)[cell viewWithTag:kProblemTypeImageTag];
    problemTypeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"problem-type-%ld", indexPath.row + 1]];

    // Configure cell label depending on problem type.
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kTitleTag];
    titleLabel.text = [self uppercaseFirstLetter:(NSString *)[ECOMAP_PROBLEM_TYPES_ARRAY objectAtIndex:indexPath.row]];
    
    // Check either filtering mask contains type of the problem of the current row
    // Depending on answer show image.
    UIImageView *checkmarkImage = (UIImageView *)[cell viewWithTag:kCheckmarkImageTag];
    checkmarkImage.image = [self checkmarkImage:[self.filteringMask.problemTypes containsObject:@(indexPath.row + 1)]];
    
    return cell;
}

- (UITableViewCell *)createProblemStatusCellForIndexPath:(NSIndexPath *)indexPath
{
    // Create cell from template
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProblemStatusCellID];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kTitleTag];
    titleLabel.text = (indexPath.row == 0) ? @"Нова" : @"Вирішена";
    
    // Check either filtering mask contains type of the problem of the current row
    // Depending on answer show image.
    UIImageView *checkmarkImage = (UIImageView *)[cell viewWithTag:kCheckmarkImageTag];
    checkmarkImage.image = (indexPath.row == 0) ? [self checkmarkImage:self.filteringMask.showSolved]
                                                : [self checkmarkImage:self.filteringMask.showUnsolved];
    
    return cell;
}

- (UITableViewCell *)createPickerCell:(NSDate *)date forIndexPath:(NSIndexPath *)indexPath
{
    // Create cell from template
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerCellID];
    
    // Configure cell data
    UIDatePicker *targetedDatePicker = (UIDatePicker *)[cell viewWithTag:kDatePickerTag];
    
    [targetedDatePicker setDate:[self dateFromIndexPath:indexPath] animated:YES];
    
    return cell;
}

- (void)hideExistingPicker {
    
    [self.tableView deleteRowsAtIndexPaths:@[self.datePickerIndexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    self.datePickerIndexPath = nil;
}


- (NSIndexPath *)calculateIndexPathForNewPicker:(NSIndexPath *)selectedIndexPath {
    
    NSIndexPath *newIndexPath;
    
    if(([self datePickerIsShown]) && (self.datePickerIndexPath.row < selectedIndexPath.row)) {
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:0];
    } else {
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row inSection:0];
    }
    
    return newIndexPath;
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath {
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Event Handlers

- (void)handleTappingDateSection:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    if([self datePickerIsShown] && (self.datePickerIndexPath.row - 1 == indexPath.row)) {
        [self hideExistingPicker];
    } else {
        NSIndexPath *newPickerIndexPath = [self calculateIndexPathForNewPicker:indexPath];
        
        if([self datePickerIsShown]) [self hideExistingPicker];
        
        [self showNewPickerAtIndex:newPickerIndexPath];
        
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:newPickerIndexPath.row + 1 inSection:0];
    }
    
    [self.tableView endUpdates];
}

- (void)handleTappingTypeSection:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 1) {
        [self.filteringMask markProblemType:indexPath.row + 1];
    }
    
    [self.tableView reloadData];
}

- (void)handleTappingStatusSection:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        self.filteringMask.showSolved = !self.filteringMask.showSolved;
    } else {
        self.filteringMask.showUnsolved = !self.filteringMask.showUnsolved;
    }
    
    [self.tableView reloadData];
}

- (IBAction)dateChanged:(UIDatePicker *)sender
{
    
    NSIndexPath *parentCellIndexPath = nil;
    
    if([self datePickerIsShown]) {
        parentCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    } else {
        return;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:parentCellIndexPath];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:sender.date];
    
    [self setDate:sender.date forIndexPath:parentCellIndexPath];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 2;
    
    switch(section) {
        case 0:
            if ([self datePickerIsShown]) numberOfRows++;
            return numberOfRows;
        case 1:
            return [ECOMAP_PROBLEM_TYPES_ARRAY count];
        case 2:
            return numberOfRows;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat rowHeight = standardRowHeight;
    
    if ([self datePickerIsShown] && ([self.datePickerIndexPath isEqual:indexPath])) {
        rowHeight = datePickerRowHeight;
    }
    
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Table cells prototypes are different for each section.
    switch (indexPath.section) {
        case 0:
            if([self datePickerIsShown] && (self.datePickerIndexPath.row == indexPath.row)) {
                return [self createPickerCell:[NSDate date] forIndexPath:indexPath];
            } else {
                return [self createDateCellForIndexPath:indexPath];
            }
        case 1: return [self createProblemTypeCellForIndexPath:indexPath];
        case 2: return [self createProblemStatusCellForIndexPath:indexPath];
    }
    
    return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: [self handleTappingDateSection:indexPath]; break;
        case 1: [self handleTappingTypeSection:indexPath]; break;
        case 2: [self handleTappingStatusSection:indexPath]; break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
