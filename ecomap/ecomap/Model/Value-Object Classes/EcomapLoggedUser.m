//
//  EcomapLoggedUser.m
//  EcomapFetcher
//
//  Created by Vasya on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapLoggedUser.h"
#import "EcomapPathDefine.h"

@interface EcomapLoggedUser ()
@property (nonatomic, readwrite) NSUInteger userID;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *surname;
@property (nonatomic, strong, readwrite) NSString *role;
@property (nonatomic, readwrite) NSUInteger iat;
@property (nonatomic, strong, readwrite) NSString *token;

@property (nonatomic, strong) EcomapLoggedUser *curretLoggedUser;
@end

@implementation EcomapLoggedUser

#pragma mark - Singleton
+ (instancetype)sharedAccount
{
    static EcomapLoggedUser *sharedAccount = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedAccount = [[EcomapLoggedUser alloc] initPrivate];
    });
    
    return sharedAccount;
}

-(instancetype)initPrivate
{
    self = [super init];
    if (self)
    {
        //Add observer to listen when to performe logout
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(logout)
                   name:@"LogoutFromEcomapNotification"
                 object:nil];
    }
    return self;
}

//Disable init method
-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Error" reason:@"Can't create instanse of this class. To login to server use EcomapUserFetcher class" userInfo:nil];
    return nil;
}

#pragma mark - Login
+ (EcomapLoggedUser *)loginUserWithInfo:(NSDictionary *)userInfo
{
    if (userInfo)
    {
        [self parseUser:userInfo];
        EcomapLoggedUser *sharedAccount = [EcomapLoggedUser sharedAccount];
        sharedAccount.curretLoggedUser = sharedAccount;
    }
    else return nil;
    
    return [EcomapLoggedUser sharedAccount];
}

+ (void)parseUser:(NSDictionary *)userInfo
{
    //Get singleton
    EcomapLoggedUser *sharedAccount = [self sharedAccount];
    
    //Parse userInfo
    if (userInfo)
    {
        sharedAccount.userID = ![[userInfo valueForKey:ECOMAP_USER_ID] isKindOfClass:[NSNull class]] ? [[userInfo valueForKey:ECOMAP_USER_ID] integerValue] : 0;
        sharedAccount.name = ![[userInfo valueForKey:ECOMAP_USER_NAME] isKindOfClass:[NSNull class]] ? [userInfo valueForKey:ECOMAP_USER_NAME] : nil;
        sharedAccount.surname = ![[userInfo valueForKey:ECOMAP_USER_SURNAME] isKindOfClass:[NSNull class]] ? [userInfo valueForKey:ECOMAP_USER_SURNAME] : @"";
        sharedAccount.role = ![[userInfo valueForKey:ECOMAP_USER_ROLE] isKindOfClass:[NSNull class]] ? [userInfo valueForKey:ECOMAP_USER_ROLE] : nil;
        sharedAccount.iat = ![[userInfo valueForKey:ECOMAP_USER_ITA] isKindOfClass:[NSNull class]] ? [[userInfo valueForKey:ECOMAP_USER_ITA] integerValue] : 0;
    }
    NSLog(@"%@",sharedAccount.name);
    
}

//Return current logged user
+(EcomapLoggedUser *)currentLoggedUser
{
    if (![[EcomapLoggedUser sharedAccount] curretLoggedUser])
    {
        return nil;
    }
    
    return [[EcomapLoggedUser sharedAccount] curretLoggedUser];
}

#pragma mark - Logout
- (void)logout
{
    if ([[EcomapLoggedUser sharedAccount] curretLoggedUser])
    {
        [[EcomapLoggedUser sharedAccount] setCurretLoggedUser:nil];
    }
}

#pragma mark - NSObject override
//Override
- (NSString *)description
{
    return [NSString stringWithFormat:@"Logged user: %@ %@ (id = %lu)", self.name, self.surname, (unsigned long)self.userID];
}

@end
