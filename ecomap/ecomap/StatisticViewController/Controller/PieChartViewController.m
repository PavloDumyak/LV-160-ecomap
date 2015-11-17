//
//  PieChartViewController.m
//  EcomapStatistics
//
//  Created by ohuratc on 03.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import "PieChartViewController.h"
#import "EcomapRevealViewController.h"
#import "XYPieChart.h"
#import "EcomapStatsFetcher.h"
#import "EcomapURLFetcher.h"
#import "EcomapPathDefine.h"
#import "EcomapStatsParser.h"
#import "GeneralStatsTopLabelView.h"
#import "GlobalLoggerLevel.h"
#import "EcomapStatistics.h"
#define NUMBER_OF_TOP_LABELS 4

@interface PieChartViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentNavigator;

@property (weak, nonatomic) IBOutlet UISegmentedControl *statsRangeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *topLabelSpinner;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *pieChartSpinner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property NSArray* names;
// Data for drawing the Pie Chart
@property (nonatomic, strong) NSMutableArray *slices;
@property (nonatomic, strong) NSArray *sliceColors;

//@property (nonatomic) NSMutableArray

@end

@implementation PieChartViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.names = @[@"Проблем", @"Голосів", @"Коментарів", @"Фотографій"];
    [self customSetup];
    EcomapStatistics *ob = [EcomapStatistics sharedInstanceStatistics];
    [ob countAllProblemsCategory];
    self.statsForPieChart = ob.forDay;
    [self setSlices:ob.forDay];
    self.generalStats = ob.test;
    [self generateTopLabelViews];
    [self.pieChartSpinner stopAnimating];
    [self resizeTopLabelViews];
    self.segmentNavigator.selectedSegmentIndex = 0;
    [self changeRangeOfShowingStats:self.segmentNavigator];
}


-(void)viewDidAppear:(BOOL)animated
{
    [self resizeTopLabelViews];
    [self drawPieChart];
    [super viewDidAppear:YES];
}

- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if (revealViewController)
    {
        [self.revealButtonItem setTarget:self.revealViewController];
        [self.revealButtonItem setAction:@selector(revealToggle:)];
        [self.navigationController.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        [self.navigationController.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resizeTopLabelViews];
    self.pieChartView.pieRadius = [self pieChartRadius];
    [self drawPieChart];
    [self switchPage];
}

#pragma mark - Properties

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * NUMBER_OF_TOP_LABELS, self.scrollView.bounds.size.height);
    _scrollView.scrollEnabled = NO;
}

- (void)setStatsForPieChart:(NSArray *)statsForPieChart
{
    _statsForPieChart = statsForPieChart;
    [self.pieChartSpinner stopAnimating];
    self.pieChartView.pieRadius = [self pieChartRadius];
    [self drawPieChart];
}

- (void)setGeneralStats:(NSArray *)generalStats
{
    _generalStats = generalStats;
    [self.topLabelSpinner stopAnimating];
}

#pragma mark - User Interaction Handlers

- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender
{
    self.pageControl.currentPage--;
    [self switchPage];
}

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender
{
    self.pageControl.currentPage++;
    [self switchPage];
}

- (IBAction)touchPageControl:(UIPageControl *)sender
{
    [self switchPage];
}

- (IBAction)changeRangeOfShowingStats:(UISegmentedControl *)sender
{
    [self resizeTopLabelViews];
    self.pieChartView.pieRadius = [self pieChartRadius];
    EcomapStatistics *ob = [EcomapStatistics sharedInstanceStatistics];
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.slices = [ob forDay];
            break;
        case 1:
              self.slices = [ob forWeek];
            break;
        case 2:
              self.slices = [ob forMonth];
            break;
        case 3:
              self.slices = [ob countAllProblemsCategory];
            break;
        case 4:
            self.slices = [ob countAllProblemsCategory];
            break;
    }
    
[self.pieChartSpinner stopAnimating];
[self drawPieChart];
}

#pragma mark - Utility Methods

- (void)generateTopLabelViews
{
    for(int i = 0; i < NUMBER_OF_TOP_LABELS; i++)
    {
        GeneralStatsTopLabelView *topLabelView = [[GeneralStatsTopLabelView alloc] init];
        topLabelView.frame = CGRectMake(0 + i * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        topLabelView.numberOfInstances = [[self.generalStats objectAtIndex:i] doubleValue];
        topLabelView.nameOfInstances = [self.names objectAtIndex:i];
        [self.scrollView addSubview:topLabelView];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * NUMBER_OF_TOP_LABELS, self.scrollView.bounds.size.height);
    [self resizeTopLabelViews];
}

- (void)resizeTopLabelViews
{
    int i = 0;
    
    for(UIView *subView in self.scrollView.subviews)
    {
        if ([subView isKindOfClass:[GeneralStatsTopLabelView class]])
        {
            [subView setFrame:CGRectMake(0 + i * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
            i++;
        }
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * NUMBER_OF_TOP_LABELS, self.scrollView.bounds.size.height);
}

- (void)switchPage
{
    [self.scrollView scrollRectToVisible:CGRectMake(self.pageControl.currentPage * self.scrollView.bounds.size.width,
                                                    0,
                                                    self.scrollView.bounds.size.width,
                                                    self.scrollView.bounds.size.height)
                                animated:YES];
}

// Convert NSInteger to EcomapStatsTimePeriod
- (EcomapStatsTimePeriod)periodForStatsByIndex:(NSInteger)index
{
    switch(index)
    {
        case 0: return EcomapStatsForLastDay;
        case 1: return EcomapStatsForLastWeek;
        case 2: return EcomapStatsForLastMonth;
        case 3: return EcomapStatsForLastYear;
        case 4: return EcomapStatsForAllTheTime;
        default: return EcomapStatsForAllTheTime;
    }
}

#pragma mark - Drawing Pie Chart

#define DEFAULT_DIAMETER_OF_PIE_CHART_FRAME 375.00
#define DEFAULT_RADIUS_OF_PIE_CHART 148.00

- (CGFloat)radiusScaleFactor
{
    if (self.pieChartView.bounds.size.height < self.pieChartView.bounds.size.width)
    {
        return self.pieChartView.bounds.size.height / DEFAULT_DIAMETER_OF_PIE_CHART_FRAME;
    }
    else
    {
        return self.pieChartView.bounds.size.width / DEFAULT_DIAMETER_OF_PIE_CHART_FRAME;
    }
}

- (CGFloat)pieChartRadius
{
    return [self radiusScaleFactor] * DEFAULT_RADIUS_OF_PIE_CHART;
}

- (void)drawPieChart
{
    self.pieChartView.pieRadius = [self pieChartRadius];
    [self.pieChartView reloadData];
    [self.pieChartView setDelegate:self];
    [self.pieChartView setDataSource:self];
    [self.pieChartView setAnimationSpeed:1.0];
    [self.pieChartView setShowPercentage:NO];
    [self.pieChartView setPieCenter:CGPointMake(self.pieChartView.bounds.size.width /2 , self.pieChartView.bounds.size.height / 2)];
    [self.pieChartView setUserInteractionEnabled:NO];
    [self.pieChartView setLabelColor:[UIColor whiteColor]];
    self.sliceColors = [self sliceColors];
    [self.pieChartView reloadData];
}

- (NSArray *)sliceColors
{
    NSMutableArray *mutableSliceColors = [[NSMutableArray alloc] init];
    
    [mutableSliceColors addObject:[UIColor purpleColor]];
    [mutableSliceColors addObject:[UIColor greenColor]];
    [mutableSliceColors addObject:[UIColor blackColor]];
    [mutableSliceColors addObject:[UIColor brownColor]];
    [mutableSliceColors addObject:[UIColor darkGrayColor]];
    [mutableSliceColors addObject:[UIColor greenColor]];
    [mutableSliceColors addObject:[UIColor yellowColor]];
    [mutableSliceColors addObject:[UIColor blueColor]];
    [mutableSliceColors addObject:[UIColor orangeColor]];
    return mutableSliceColors;
}

#pragma mark - Fetching

- (void)fetchStatsForPieChart
{
    [self.pieChartSpinner startAnimating];
    [self.pieChartSpinner stopAnimating];
    [self drawPieChart];
}

- (void)fetchGeneralStats
{
    self.generalStats = nil;
    [self.topLabelSpinner startAnimating];
    
    [EcomapStatsFetcher loadGeneralStatsOnCompletion:^(NSArray *stats, NSError *error) {
        if (!error)
        {
            self.generalStats = stats;
            [self.topLabelSpinner stopAnimating];
            [self generateTopLabelViews];
        }
        else
        {
            DDLogError(@"Error: %@", error);
        }
    }];
}

#pragma mark - UIScroll View Delegate

// Disable zooming in scroll view
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return [self.slices count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.sliceColors objectAtIndex:index];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    DDLogVerbose(@"will select slice at index %lu",(unsigned long)index);
}

- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    DDLogVerbose(@"will deselect slice at index %lu",(unsigned long)index);
}

- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    DDLogVerbose(@"did deselect slice at index %lu",(unsigned long)index);
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    DDLogVerbose(@"did select slice at index %lu",(unsigned long)index);
}

@end
