//
//  EcomapCommentsChild.h
//  ecomap
//
//  Created by Mikhail on 2/16/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapActivity.h"

@interface EcomapCommentaries : EcomapActivity
+(EcomapCommentaries*)sharedInstance;
-(void)setCommentariesArray:(NSArray*)comentArray :(NSUInteger)probId;
@property (nonatomic, readwrite) NSArray* comInfo;
@property (nonatomic, readwrite) NSUInteger problemsID;
@end
