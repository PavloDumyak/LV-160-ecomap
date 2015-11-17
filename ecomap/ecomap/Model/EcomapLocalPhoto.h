//
//  LocalPhotoDescription.h
//  ecomap
//
//  Created by Inna Labuskaya on 2/25/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EcomapLocalPhoto : NSObject

- (instancetype)initWithImage:(UIImage*)image;
- (instancetype)initWithImage:(UIImage*)image description:(NSString*)description;

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong) NSString *imageDescription;

@end
