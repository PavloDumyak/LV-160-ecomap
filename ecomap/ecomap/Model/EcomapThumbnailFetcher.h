//
//  EcomapThumbnailFetcher.h
//  ecomap
//
//  Created by Vasya on 3/1/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapFetcher.h"

@interface EcomapThumbnailFetcher : EcomapFetcher

//Load small image (for thumnails)
+ (void)loadSmallImagesFromLink:(NSString *)link OnCompletion:(void (^)(UIImage *image, NSError *error))completionHandler;

@end
