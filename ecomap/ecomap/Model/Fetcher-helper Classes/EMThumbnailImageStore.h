//
//  EMThumbnailImageStore.h
//  ecomap
//
//  Created by Vasya on 2/17/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EMThumbnailImageStore : NSObject
//This class is storage for small images cache;

//Singleton
+(instancetype)sharedStore;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
@end
