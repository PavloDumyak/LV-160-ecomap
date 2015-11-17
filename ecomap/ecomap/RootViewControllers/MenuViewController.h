//
//  MenuTableViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWUITableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *label;
@end

@interface SWUIUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellName;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@end


@interface MenuViewController : UITableViewController

@end
