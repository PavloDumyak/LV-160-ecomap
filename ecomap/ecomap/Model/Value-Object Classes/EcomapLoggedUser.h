//
//  EcomapLoggedUser.h
//  EcomapFetcher
//
//  Created by Vasya on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapLoggedUser : NSObject
@property (nonatomic, readonly) NSUInteger userID;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *surname;
@property (nonatomic, strong, readonly) NSString *role;
@property (nonatomic, readonly) NSUInteger iat; //timeInterval since 1970
@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, strong) NSString *email;

//To login user
+ (EcomapLoggedUser *)loginUserWithInfo:(NSDictionary *)userInfo; //userInfo is response from Ecomap server

//Get current logged user object
//Return nil if no user is currently logged in
+(EcomapLoggedUser *)currentLoggedUser;

@end
