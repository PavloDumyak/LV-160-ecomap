//
//  ProblemFilterTVC.m
//  ecomap
//
//  Created by ohuratc on 05.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
///

#import "ProblemFilterTVC.h"
#import "EcomapPathDefine.h"
#import "InfoActions.h"
#import "EcomapProblemFilteringMask.h"
#import "EcomapLoggedUser.h"

static const NSInteger numberOfSections = 4;

static const float standardRowHeight = 44.0;
static const float datePickerRowHeight = 164;

static const int kDatePickerTag = 101;
static const int kProblemTypeImageTag = 102;
static const int kTitleTag = 103;
static const int kCheckmarkImageTag = 104;

static NSString *kDateCellID = @"dateCell";
static NSString *kProblemTypeCellID = @"problemTypeCell";
static NSString *kProblemStatusCellID = @"problemStatusCell";
static NSString *kDatePickerCellID = @"datePickerCell";
static NSString *kproblemOwnerCellID = @"ownerProblemCell";

@interface ProblemFilterTVC ()

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
    
}

#pragma mark - Properties

- (EcomapProblemFilteringMask *)filteringMask
{
    if (!_filteringMask)
    {
        _filteringMask = [[EcomapProblemFilteringMask alloc] init];
    }
    return _filteringMask;
}

// Get date for index path from filtering mask.
- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *parentCellIndexPath = indexPath;
    
    if ([self datePickerIsShown])
    {
        parentCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    }
    
    return (parentCellIndexPath.row == 0) ? self.filteringMask.fromDate : self.filteringMask.toDate;
}

// Set date in filtering mask from index path.
- (void)setDate:(NSDate *)date fromIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        self.filteringMask.fromDate = date;
    }
    else
    {
        self.filteringMask.toDate = date;
    }
}

#pragma mark - Helper Methods

- (void)createDateFormatter
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
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

// Check dates validity.
- (BOOL)isDatesValid
{
    if (self.filteringMask.fromDate.timeIntervalSince1970 < self.filteringMask.toDate.timeIntervalSince1970)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)datePickerIsShown
{
    return self.datePickerIndexPath != nil;
}

- (void)hideExistingPicker
{
    
    [self.tableView deleteRowsAtIndexPaths:@[self.datePickerIndexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    self.datePickerIndexPath = nil;
}


- (NSIndexPath *)calculateIndexPathForNewPicker:(NSIndexPath *)selectedIndexPath
{
    NSIndexPath *newIndexPath;
    
    if (([self datePickerIsShown]) && (self.datePickerIndexPath.row < selectedIndexPath.row))
    {
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:0];
    }
    else
    {
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row inSection:0];
    }
    
    return newIndexPath;
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath
{
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Cell Creator Methods
- (UITableViewCell *)createDateCellForIndexPath:(NSIndexPath *)indexPath
{
    // Create cell from template
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDateCellID];
    
    // Configure cell data
    cell.textLabel.text = (indexPath.row == 0) ? NSLocalizedString(@"Показати з:", @"Show from")  : NSLocalizedString(@"Показати до:", @"Show up to");
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[self dateForIndexPath:indexPath]];
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
    titleLabel.text = [ECOMAP_PROBLEM_TYPES_ARRAY objectAtIndex:indexPath.row];
    
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
    titleLabel.text = (indexPath.row == 0) ? NSLocalizedString(@"Нова", @"New") : NSLocalizedString(@"Вирішена", @"Solved");
    
    // Check either filtering mask contains type of the problem of the current row
    // Depending on answer show image.
    UIImageView *checkmarkImage = (UIImageView *)[cell viewWithTag:kCheckmarkImageTag];
    checkmarkImage.image = (indexPath.row == 0) ? [self checkmarkImage:self.filteringMask.showUnsolved]
    : [self checkmarkImage:self.filteringMask.showSolved];
    
    return cell;
}

//cell for new filter
- (UITableViewCell *)createProblemOwnerCellForIndexPath:(NSIndexPath *)indexPath
{
    // Create cell from template
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kproblemOwnerCellID];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kTitleTag];
    titleLabel.text = NSLocalizedString(@"Відображати тільки мої проблеми", @"Show only my problems");
    
    // Check either filtering mask contains type of the problem of the current row
    // Depending on answer show image.
    UIImageView *checkmarkImage = (UIImageView *)[cell viewWithTag:kCheckmarkImageTag];
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
    if (!userIdent)
    {
        self.filteringMask.showCurrentUserProblem = NO;
        titleLabel.textColor = [UIColor grayColor];
    }
    else
    {
        titleLabel.textColor = [UIColor blackColor];
    }
    
    checkmarkImage.image = [self checkmarkImage:self.filteringMask.showCurrentUserProblem];
    
    return cell;
}

- (UITableViewCell *)createPickerCell:(NSDate *)date forIndexPath:(NSIndexPath *)indexPath
{
    // Create cell from template
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerCellID];
    
    // Configure cell data
    UIDatePicker *targetedDatePicker = (UIDatePicker *)[cell viewWithTag:kDatePickerTag];
    
    //Create date 18-02-2014 (first problem added on Ecomap)
    NSDateComponents *minDate = [[NSDateComponents alloc] init];
    minDate.day = 18;
    minDate.month = 02;
    minDate.year = 2014;
    
    targetedDatePicker.minimumDate = [[NSCalendar currentCalendar] dateFromComponents:minDate];
    //[self.dateFormatter dateFromString:@"18-02-2014"];
    targetedDatePicker.maximumDate = [NSDate date];
    
    [targetedDatePicker setDate:[self dateForIndexPath:indexPath] animated:YES];
    
    return cell;
}

#pragma mark - Event Handlers

- (void)handleTappingDateSection:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    if ([self datePickerIsShown] && (self.datePickerIndexPath.row - 1 == indexPath.row))
    {
        [self hideExistingPicker];
    }
    else
    {
        NSIndexPath *newPickerIndexPath = [self calculateIndexPathForNewPicker:indexPath];
        
        if ([self datePickerIsShown])
        {
            [self hideExistingPicker];
        }
        
        [self showNewPickerAtIndex:newPickerIndexPath];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:newPickerIndexPath.row + 1 inSection:0];
    }
    [self.tableView endUpdates];
}

- (void)handleTappingTypeSection:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1)
    {
        [self.filteringMask markProblemType:indexPath.row + 1];
    }
    
    [self.tableView reloadData];
}

- (void)handleTappingStatusSection:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        self.filteringMask.showUnsolved = !self.filteringMask.showUnsolved;
    }
    else
    {
        self.filteringMask.showSolved = !self.filteringMask.showSolved;
    }
    
    [self.tableView reloadData];
}

//handle to new filter mine
- (void)handleTappingOwnerSection:(NSIndexPath *)indexPath
{
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
    if (!userIdent)
    {
        return;
    }
    if (indexPath.row == 0)
    {
        self.filteringMask.showCurrentUserProblem = !self.filteringMask.showCurrentUserProblem;
    }
    
    [self.tableView reloadData];
}

- (IBAction)dateChanged:(UIDatePicker *)sender
{
    
    NSIndexPath *parentCellIndexPath = nil;
    
    if ([self datePickerIsShown])
    {
        parentCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        return;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:parentCellIndexPath];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:sender.date];
    
    [self setDate:sender.date fromIndexPath:parentCellIndexPath];
}

// Hide view controller
- (IBAction)touchHideButton:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Send message userDidApplyFilteringMask: to delegate.
- (IBAction)touchApplyButton:(UIBarButtonItem *)sender
{
    
    if ([self isDatesValid])
    {
        [self dismissViewControllerAnimated:YES completion:^{ [self.delegate userDidApplyFilteringMask:self.filteringMask]; }];
    }
    else
    {
        [InfoActions showAlertWithTitile:NSLocalizedString(@"Увага!", @"Attention")
                              andMessage:NSLocalizedString(@"Дата початку періоду повинна бути більшою за дату кінця періоду",
                                                           @"Starting date of the period must be greater than the date of the end of the period")];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 2;
    
    switch(section)
    {
        case 0:
            if ([self datePickerIsShown]) numberOfRows++;
            return numberOfRows;
        case 1:
            return [ECOMAP_PROBLEM_TYPES_ARRAY count];
        case 2:
            return numberOfRows;
        case 3:
            return 1;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat rowHeight = standardRowHeight;
    
    if ([self datePickerIsShown] && ([self.datePickerIndexPath isEqual:indexPath]))
    {
        rowHeight = datePickerRowHeight;
    }
    
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Table cells prototypes are different for each section.
    switch (indexPath.section)
    {
        case 0:
            if ([self datePickerIsShown] && (self.datePickerIndexPath.row == indexPath.row))
            {
                return [self createPickerCell:[NSDate date] forIndexPath:indexPath];
            }
            else
            {
                return [self createDateCellForIndexPath:indexPath];
            }
        case 1:
            return [self createProblemTypeCellForIndexPath:indexPath];
        case 2:
            return [self createProblemStatusCellForIndexPath:indexPath];
        case 3:
            return [self createProblemOwnerCellForIndexPath:indexPath];
    }
    
    return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
            return NSLocalizedString(@"Фільтрація за датою", @"Filter by date");
        case 1:
            return NSLocalizedString(@"Типи проблем", @"Problem types");
        case 2:
            return NSLocalizedString(@"Статус проблеми", @"Problem status");
        case 3:
            return NSLocalizedString(@"Мої проблеми", @"My problems");
    }
    
    return @"";
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            [self handleTappingDateSection:indexPath]; break;
        case 1:
            [self handleTappingTypeSection:indexPath]; break;
        case 2:
            [self handleTappingStatusSection:indexPath]; break;
        case 3:
            [self handleTappingOwnerSection:indexPath]; break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
