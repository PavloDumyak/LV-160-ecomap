//
//  PieChartLegendViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 20.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "PieChartLegendViewController.h"
#import "PieChartLegendTableViewCell.h"

@interface PieChartLegendViewController ()
{
    NSArray *colors;
    NSArray *labels;
}


@end

@implementation PieChartLegendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    colors = [self createColorsArray];
    labels = [self createLabelsArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSArray*)createColorsArray
{
    return  @[[UIColor colorWithRed:80/255.0 green:9/255.0 blue:91/255.0 alpha:1],
              [UIColor colorWithRed:9/255.0 green:91/255.0 blue:15/255.0 alpha:1],
              [UIColor colorWithRed:35/255.0 green:31/255.0 blue:32/255.0 alpha:1],
              [UIColor colorWithRed:152/255.0 green:68/255.0 blue:43/255.0 alpha:1],
              [UIColor colorWithRed:27/255.0 green:154/255.0 blue:214/255.0 alpha:1],
              [UIColor colorWithRed:113/255.0 green:191/255.0 blue:168/255.0 alpha:1],
              [UIColor colorWithRed:255/255.0 green:171/255.0 blue:9/255.0 alpha:1]];
}

- (NSArray*)createLabelsArray
{
    return @[NSLocalizedString(@"Інші проблеми", nil),
             NSLocalizedString(@"Проблеми лісів", nil),
             NSLocalizedString(@"Сміттєзвалища", nil),
             NSLocalizedString(@"Незаконна забудова", nil),
             NSLocalizedString(@"Проблеми водойм", nil),
             NSLocalizedString(@"Загрози біорізноманіттю", nil),
             NSLocalizedString(@"Браконьєрство", nil)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [labels count];
}

- (IBAction)closeLegend:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PieChartLegendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[PieChartLegendTableViewCell alloc] init];
    }
    cell.colorView.backgroundColor = colors[indexPath.row];
    cell.problemType.text = labels[indexPath.row];
    return cell;
}

@end
