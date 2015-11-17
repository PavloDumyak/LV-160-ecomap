//
//  EcomapUserFetcher.m
//  ecomap
//
//  Created by Vasya on 3/1/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapUserFetcher.h"
#import "DataTasks.h"
#import "JSONParser.h"
#import "NetworkActivityIndicator.h"
#import <FacebookSDK/FacebookSDK.h>

//Value-Object classes
#import "EcomapLoggedUser.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"


static BOOL calledFacebookCloseSession = NO;

@implementation EcomapUserFetcher
#pragma mark - Login
+ (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(EcomapLoggedUser *loggedUser, NSError *error))completionHandler
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@"YES" forKey:@"isLogged"];
    [ud setObject:email forKey:@"email"];
    [ud setObject:password forKey:@"password"];
    
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    //[sessionConfiguration setHTTPAdditionalHeaders:[request setValue:@"application/xml" forHTTPHeaderField:@"content-type"];]
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforLogin]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"email" : email, @"password" : password};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData
                                                   options:0
                                                     error:nil];
    
    [DataTasks uploadDataTaskWithRequest:request
                                fromData:data
                    sessionConfiguration:sessionConfiguration
                       completionHandler:^(NSData *JSON, NSError *error) {
                           EcomapLoggedUser *loggedUser = nil;
                           NSDictionary *userInfo = nil;
                           if (!error) {
                               //Parse JSON
                               userInfo = [JSONParser parseJSONtoDictionary:JSON];
                               //Create EcomapLoggedUser object
                               loggedUser = [EcomapLoggedUser loginUserWithInfo:userInfo];

                               
                               if (loggedUser) {
                                   loggedUser.email = email;
                                 //  loggedUser
                                   
                                   DDLogVerbose(@"LogIN to ecomap success! %@", loggedUser.description);
                                   
                                   //Create cookie
                                   NSHTTPCookie *cookie = [self createCookieForUser:[EcomapLoggedUser currentLoggedUser]];
                                   if (cookie) {
                                       DDLogVerbose(@"Cookies created success!");
                                       //Put cookie to NSHTTPCookieStorage
                                       [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
                                       [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:@[cookie]
                                                                                          forURL:[EcomapURLFetcher URLforServer]
                                                                                 mainDocumentURL:nil];
                                   }
                               }
                           } else {
                               DDLogError(@"Error to login to ecomap server: %@", [error localizedDescription]);
                           }
                           
                           //set up completionHandler
                           completionHandler(loggedUser, error);
                       }];
}

#define FACEBOOK_PERMISSIONS @[@"public_profile", @"email"]
#define FACEBOOK_INFO_PARAMETERS @{@"fields": @"first_name, last_name, email"}
+ (void)loginWithFacebookOnCompletion:(void (^)(EcomapLoggedUser *loggedUserFB, NSError *error))completionHandler
{
    //check current FB session state
    if ([FBSession activeSession].state != FBSessionStateOpen &&
        [FBSession activeSession].state != FBSessionStateOpenTokenExtended) {
        
        [FBSession openActiveSessionWithReadPermissions:FACEBOOK_PERMISSIONS
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          
                                          // Handle the session state.
                                          // Usually, the only interesting states are the opened session, the closed session and the failed login.
                                          if (!error) {
                                              // In case that there's not any error, then check if the session opened or closed.
                                              if (status == FBSessionStateOpen) {
                                                  DDLogVerbose(@"Facebook session open success!");
                                                  
                                                  // The session is open. Get the user information from Facebook.
                                                  [self requestUserInfoFromFacebookOnCompletion:^(id result, NSError *error) {
                                                      if (!error) {
                                                          //Login to Ecomap server with info received from Faceboom
                                                          [self loginToEcomapWithInfoReceicedFromFacebook:result
                                                                                     OnCompletion:^(EcomapLoggedUser *loggedUserFB, NSError *error) {
                                                                                         if (!error) {
                                                                                             completionHandler(loggedUserFB, nil);
                                                                                         } else {
                                                                                             // In case an error to login to Ecomap with user info from Facebook
                                                                                             [self closeFacebookSession];
                                                                                             completionHandler (nil, error);
                                                                                         }
                                                                                     }];//end of "loginWithInfoReceicedFromFacebook" complition block
                                                      } else {
                                                          // In case an error to receive user info from Faceboom
                                                          [self closeFacebookSession];
                                                          completionHandler (nil, error);
                                                      }
                                                  }]; //end of "requestUserInfoFromFacebookOnCompletion" complition block
                                                  
                                                  
                                              } else if (status == FBSessionStateClosed || status == FBSessionStateClosedLoginFailed){
                                                  // A session was closed or the login was failed or canceled.
                                                  if (!calledFacebookCloseSession) {
                                                      //Stop network activity indicator
                                                      [[NetworkActivityIndicator sharedManager]endActivity];
                                                      
                                                      DDLogError(@"Error login with facebook: a session was closed or the login was failed or canceled");
                                                      completionHandler (nil, nil);
                                                  }
                                                  
                                              }
                                          } else{
                                              // In case an error to connect to facebook (open session) has occured.
                                              DDLogError(@"Error to open facebook session: %@", [error localizedDescription]);
                                              completionHandler (nil, error);
                                          }
                                      }]; //end of "FB onopenActiveSession" complition block
    } else {
        //The FB sessiom is in state "open" or "OpenTokenExtended"
        [self closeFacebookSession];
        
        //Stop network activity indicator
        [[NetworkActivityIndicator sharedManager] endActivity];
        
        //Return complition handler
        completionHandler(nil, nil);
    }
    
}

+ (void)requestUserInfoFromFacebookOnCompletion:(void (^)(id result, NSError *error))completionHandler
{
    [[NetworkActivityIndicator sharedManager] startActivity];
    
    [FBRequestConnection startWithGraphPath:@"me"
                                 parameters:FACEBOOK_INFO_PARAMETERS
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              //Stop network activity indicator
                              [[NetworkActivityIndicator sharedManager]endActivity];
                              
                              if (!error) {
                                  //Parse FB response
                                  NSString *name = [result objectForKey:@"first_name"];
                                  NSString *surname = [result objectForKey:@"last_name"];
                                  DDLogVerbose(@"User (%@ %@) info received from facebook!", name, surname);
                                  completionHandler(result, nil);
                              } else {
                                  //In case an error to get user info from facebook has occured
                                  DDLogError(@"Error getting user info from facebook: %@", [error localizedDescription]);
                                  completionHandler (nil, error);
                              }
                          }];  //end of FBRequestConnection complition block
}

+ (void)loginToEcomapWithInfoReceicedFromFacebook:(id)result OnCompletion:(void (^)(EcomapLoggedUser *loggedUserFB, NSError *error))completionHandler
{
    //Parse FB response
    NSString *name = [result objectForKey:@"first_name"];
    NSString *surname = [result objectForKey:@"last_name"];
    NSString *email = [result objectForKey:@"email"];
    NSString *password = [result objectForKey:@"id"];
    DDLogVerbose(@"Try to login Facebook user (%@ %@) on Ecomap server!", name, surname);
    
    //Try to login (first effort). If not success, then try to register and login again
    [self loginWithEmail:email
             andPassword:password
            OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                if (!error && loggedUser) {
                    completionHandler (loggedUser, nil);
                } else {
                    // In case an error to login (first effort) has occured
                    //Try to register
                    [self registerWithName:name
                                andSurname:surname
                                  andEmail:email
                               andPassword:password
                              OnCompletion:^(NSError *error) {
                                  if (!error) {
                                      //Try to login (second effort)
                                      [self loginWithEmail:email
                                               andPassword:password
                                              OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                                                  if (!error && loggedUser) {
                                                      completionHandler (loggedUser, nil);
                                                      //return;
                                                  } else {
                                                      // In case an error to login (second effort) has occured
                                                      completionHandler (nil, error);
                                                  }
                                              }]; //end of login (second effort) complition block
                                  } else {
                                      // In case an error to register has occured.
                                      completionHandler (nil, error);
                                  }
                              }];  //end of registartiom complition block
                }
            }]; //end of login (first effort) complition block
}

+ (void)closeFacebookSession
{
    
    calledFacebookCloseSession = YES;
    [[FBSession activeSession] close];
    DDLogVerbose(@"Facebook session closed");
}

#pragma mark - Change password
+ (void)changePassword:(NSString*)oldPassword toNewPassword:(NSString*)newPassword OnCompletion:(void (^)(NSError *error))completionHandler
{
    if (![EcomapLoggedUser currentLoggedUser]) {
        //There is no logged user. Form Error
        NSError *error = [[NSError alloc] initWithDomain:NSMachErrorDomain
                                                    code:600
                                                userInfo:@{@"error" : @"There is no logged user"}];
        completionHandler(error);
        return;
    }
    //{"userId":"1", "old_password": "admin", "new_password":"admin", "new_password_second":"admin"}
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforChangePassword]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"userId": [NSNumber numberWithInteger:[[EcomapLoggedUser currentLoggedUser] userID]],
                                @"old_password":oldPassword,
                                @"new_password" : newPassword,
                                @"new_password_second" : newPassword};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData
                                                   options:0
                                                     error:nil];
    [DataTasks uploadDataTaskWithRequest:request
                                fromData:data
                    sessionConfiguration:sessionConfiguration
                       completionHandler:^(NSData *JSON, NSError *error) {
                           if (!error) {
                               DDLogVerbose(@"Password changed success!");
                           } else {
                               DDLogError(@"Error to change password: %@", [error localizedDescription]);
                           }
                           
                           //set up completionHandler
                           completionHandler(error);
                       }];
}

#pragma mark - Logout
+ (void)logoutUser:(EcomapLoggedUser *)loggedUser OnCompletion:(void (^)(BOOL result, NSError *error))completionHandler
{
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforLogout]]
              sessionConfiguration:sessionConfiguration
                 completionHandler:^(NSData *JSON, NSError *error) {
                     BOOL result = NO;
                     if (!error) {
                         NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                         [ud setObject:@"NO" forKey:@"isLogged"];
                         //Read response Data (it is not JSON actualy, just plain text)
                         NSString *statusResponse =[[NSString alloc]initWithData:JSON encoding:NSUTF8StringEncoding];
                         result = [statusResponse isEqualToString:@"OK"] ? YES : NO;
                         DDLogVerbose(@"Logout %@!", statusResponse);
                         
                         //Clear coockies
                         NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[EcomapURLFetcher URLforServer]];
                         for (NSHTTPCookie *cookie in cookies) {
                             [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                         }
                         
                         //post Logout notification
                         if (loggedUser) {
                             NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                             [nc postNotificationName:@"LogoutFromEcomapNotification" object:nil];
                         }
                     } else {
                         DDLogError(@"Error to logout from ecomap server: %@", [error localizedDescription]);
                     }
                     completionHandler(result, error);
                 }];
    
    //Close facebook session if there is one
    if ([FBSession activeSession].state == FBSessionStateOpen ||
        [FBSession activeSession].state == FBSessionStateOpenTokenExtended) {
        [self closeFacebookSession];
    }
}

#pragma mark - Register
+ (void)registerWithName:(NSString*)name andSurname:(NSString*) surname andEmail: (NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(NSError *error))completionHandler{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforRegister]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"password" : password, @"first_name": name, @"last_name":surname, @"email" : email};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData
                                                   options:0
                                                     error:nil];
    [DataTasks uploadDataTaskWithRequest:request
                                fromData:data
                    sessionConfiguration:sessionConfiguration
                       completionHandler:^(NSData *JSON, NSError *error) {
                           if (!error) {
                               DDLogVerbose(@"Register to ecomap success!");
                           } else {
                               DDLogError(@"Error to register on ecomap server: %@", [error localizedDescription]);
                           }
                           
                           //set up completionHandler
                           completionHandler(error);
                       }];
}

#pragma mark - Cookies
+ (NSHTTPCookie *)createCookieForUser:(EcomapLoggedUser *)userData
{
    NSHTTPCookie *cookie = nil;
    if (userData) {
        //Form userName value
        NSString *userName = userData.name ? userData.name : @"null";
        userName = [userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *userNameValue = [NSString stringWithFormat:@"userName=%@", userName];
        
        //Form userSurname value
        NSString *userSurname = userData.surname ? userData.surname : @"null";
        userSurname = [userSurname stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *userSurnameValue = [NSString stringWithFormat:@"userSurname=%@", userSurname];
        
        //Form userRole value
        NSString *userRole = userData.role ? userData.role : @"null";
        NSString *userRoleValue = [NSString stringWithFormat:@"userRole=%@", userRole];
        
        //Form token value
        NSString *token = userData.token ? userData.token : @"null";
        NSString *tokenValue = [NSString stringWithFormat:@"token=%@", token];
        
        //Form id value
        NSString *idValue = [NSString stringWithFormat:@"id=%lu", (unsigned long)userData.userID];
        
        //Form userEmail value
        NSString *userEmail = userData.email ? [userData.email stringByReplacingOccurrencesOfString:@"@" withString:@"%"] : @"null";
        NSString *userEmailValue = [NSString stringWithFormat:@"userEmail=%@", userEmail];
        
        //Form cookie value
        NSString *cookieValue = [NSString stringWithFormat:@"%@; %@; %@; %@; %@; %@", userNameValue, userSurnameValue, userRoleValue, tokenValue, idValue, userEmailValue];
        
        //Form cookie properties
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [EcomapURLFetcher serverDomain], NSHTTPCookieDomain,
                                    @"/", NSHTTPCookiePath,
                                    @"ECOMAPCOOKIE", NSHTTPCookieName,
                                    cookieValue, NSHTTPCookieValue,
                                    [[NSDate date] dateByAddingTimeInterval:864000], NSHTTPCookieExpires, //10 days
                                    nil];
        
        //Form cookie
        cookie = [NSHTTPCookie cookieWithProperties:properties];
    }
    
    return cookie;
}



@end
