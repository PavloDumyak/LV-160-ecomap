//
//  ECMEditableProblem.h
//  ecomap
//
//  Created by ohuratc on 02.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcomapProblemDetails.h"

@interface EcomapEditableProblem : NSObject;

@property (nonatomic, strong) NSString *content;
@property (nonatomic, getter=isSolved) BOOL solved;
@property (nonatomic, strong) NSString *proposal;
@property (nonatomic) NSUInteger severity;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithProblem:(EcomapProblemDetails *)problem; // Designated initializer

@end
