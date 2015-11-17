//
//  PhotoViewController.h
//  ecomap
//
//  Created by Inna Labuskaya on 2/24/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EcomapLocalPhoto.h"

@class PhotoViewController;

@protocol PhotoViewControllerDelegate <NSObject>

- (void)photoViewControllerDidFinish:(PhotoViewController*)viewController
               withImageDescriptions:(NSArray*)imageDescriptions;
- (void)photoViewControllerDidCancel:(PhotoViewController*)viewController;

@end

@interface PhotoViewController : UIViewController

@property (nonatomic, weak) id<PhotoViewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger maxPhotos;

@end
