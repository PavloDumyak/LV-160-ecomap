//
//  EcomapThumbnailFetcher.m
//  ecomap
//
//  Created by Vasya on 3/1/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapThumbnailFetcher.h"
#import "DataTasks.h"
#import "EMThumbnailImageStore.h"
#import "EcomapURLFetcher.h"
#import "InfoActions.h"

@implementation EcomapThumbnailFetcher

#pragma mark - Load image
+ (void)loadSmallImagesFromLink:(NSString *)link OnCompletion:(void (^)(UIImage *image, NSError *error))completionHandler
{
    [DataTasks downloadDataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforSmallPhotoWithLink:link]]
                      sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                         completionHandler:^(NSData *data, NSError *error) {
                             UIImage *image = nil;
                             if (!error) {
                                 if (data) {
                                     image = [UIImage imageWithData:data];
                                     //Make thumnail image
                                     image = [self makeThumbnailFromImage:image];
                                     //Cache image
                                     [[EMThumbnailImageStore sharedStore] setImage:image forKey:link];
                                 }
                             }
                             //Return image
                             completionHandler(image, error);
                         }];
}

//Make small image with roundeded rect
//This method will take a full-sized image, create a smaller representation of it in an offscreen graphics context object
+ (UIImage *)makeThumbnailFromImage:(UIImage *)image
{
    UIImage *thumbnail = nil;
    CGSize origImageSize = image.size;
    
    //The rectangle of the thumbnail
    CGRect newRect = CGRectMake(0, 0, 80, 80);
    
    //Figure out a scaling ratio to make sure we maintain the same aspect ratio
    float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);
    
    //Create a transparent bitmap context with a scaling factor
    //equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    //Create a path that is a rounded rectangle
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    
    //Make all subsequent drawing clip to this rounded rectangle
    [path addClip];
    
    //Center the image in the thumbnail rectangle
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    //Draw the image on it
    [image drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    thumbnail = smallImage;
    
    //clean up image context resources
    UIGraphicsEndImageContext();
    
    return thumbnail;
}

@end
