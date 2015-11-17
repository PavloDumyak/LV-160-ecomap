//
//  ECMAdminFetcher.h
//  ecomap
//
//  Created by ohuratc on 02.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapFetcher.h"
#import "EcomapEditableProblem.h"

@interface EcomapAdminFetcher : EcomapFetcher

+ (void)deletePhotoWithLink:(NSString*)link onCompletion:(void(^)(NSError *error))completionHandler;

@end
