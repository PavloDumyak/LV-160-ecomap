//
//  CommentCell.h
//  ecomap
//
//  Created by Mikhail on 2/19/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditCommentProtocol <NSObject>

-(void)editComentWithID:(NSIndexPath *)commentIndexPath withContent:(NSString *)content;

@end

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *commentContent;
@property (weak, nonatomic) IBOutlet UILabel *personInfo;
@property (weak, nonatomic) IBOutlet UILabel *dateInfo;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (assign, nonatomic) NSIndexPath* indexPathOfRow;

- (IBAction)editButton:(UIButton *)sender;

@property (weak, nonatomic) id <EditCommentProtocol> delegate;

@end
