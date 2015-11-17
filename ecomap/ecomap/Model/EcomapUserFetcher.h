//
//  EcomapUserFetcher.h
//  ecomap
//
//  Created by Vasya on 3/1/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapFetcher.h"

@interface EcomapUserFetcher : EcomapFetcher

#pragma mark - GET API
//Logout
+ (void)logoutUser:(EcomapLoggedUser *)loggedUser OnCompletion:(void (^)(BOOL result, NSError *error))completionHandler;

#pragma mark - POST API
//Login
//Use [EcomapLoggedUser currentLoggedUser] to get an instance of current logged user anytime
+ (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(EcomapLoggedUser *loggedUser, NSError *error))completionHandler;

+ (void)changePassword:(NSString*)oldPassword toNewPassword:(NSString*)newPassword OnCompletion:(void (^)(NSError *error))completionHandler;

+ (void)loginWithFacebookOnCompletion:(void (^)(EcomapLoggedUser *loggedUserFB, NSError *error))completionHandler;

//Registration.
+ (void)registerWithName:(NSString*)name andSurname:(NSString*) surname andEmail: (NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(NSError *error))completionHandler;


@end
