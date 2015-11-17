//
//  PieChartLegendTableViewCell.h
//  ecomap
//
//  Created by Anton Kovernik on 20.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieChartLegendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *problemType;

@end
