//
//  EcomapAlias.h
//  ecomap
//
//  Created by Mikhail on 2/6/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapAlias : NSObject
@property (nonatomic, strong, readonly) NSString *content; // content of resource/alias (HTML)

//Designated initializer
-(instancetype)initWithAlias:(NSDictionary *)alias;
-(void)parseAlias:(NSDictionary *)alias;    //parsing

@end
