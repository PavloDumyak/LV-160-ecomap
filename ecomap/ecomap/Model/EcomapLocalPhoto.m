//
//  LocalPhotoDescription.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/25/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapLocalPhoto.h"

@interface EcomapLocalPhoto()

@property (nonatomic, strong, readwrite) UIImage *image;

@end

@implementation EcomapLocalPhoto

- (instancetype)initWithImage:(UIImage*)image
{
    return [self initWithImage:image description:nil];
}

- (instancetype)initWithImage:(UIImage*)image description:(NSString*)description
{
    self = [super init];
    if (self)
    {
        self.image = image;
        self.imageDescription = description;
    }
    return self;
}

@end
