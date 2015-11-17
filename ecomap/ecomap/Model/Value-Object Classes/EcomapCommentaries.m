//
//  EcomapCommentsChild.m
//  ecomap
//
//  Created by Mikhail on 2/16/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapCommentaries.h"
#import "EcomapPathDefine.h"

@interface EcomapCommentaries ()
@property (nonatomic, readwrite) NSUInteger commentID;
@property (nonatomic, strong, readwrite) NSString *content;
@property (nonatomic, strong, readwrite) NSDate *date;
@property (nonatomic, readwrite) NSUInteger activityTypes_Id;
@property (nonatomic, readwrite) NSUInteger usersID;
@property (nonatomic, readwrite) NSString *problemContent;
@property (nonatomic, readwrite) NSString *userName;
@property (nonatomic, readwrite) NSString *userSurname;
@property BOOL flagComment;

@end

@implementation EcomapCommentaries
@synthesize  commentID, content, date, activityTypes_Id, usersID, problemsID, problemContent, userName, userSurname;

+ (EcomapCommentaries*)sharedInstance
{
    static EcomapCommentaries* singleton;
    static dispatch_once_t token;
    dispatch_once(&token, ^{singleton = [[EcomapCommentaries alloc] init];});
    
    return singleton;
}

- (void)setCommentariesArray:(NSArray *)comentArray :(NSUInteger)probId
{
    EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
    ob.comInfo = comentArray;    
    ob.problemsID = probId;
}

- (instancetype)initWithInfo:(NSDictionary *)problem
{
    self = [super init];
   
    if (self)
    {
        if (!problem) return nil;
        self.commentID = [[problem valueForKey:ECOMAP_COMMENT_ID]  isKindOfClass:[NSNumber class]] ? [[problem valueForKey:ECOMAP_COMMENT_ID] integerValue] : 0;
        NSLog(@"%@",[problem valueForKey:ECOMAP_COMMENT_ID]);
        self.content = [[problem valueForKey:ECOMAP_COMMENT_CONTENT] isKindOfClass:[NSString class]] ? [problem valueForKey:ECOMAP_COMMENT_CONTENT] : @"";
        NSData *data = [self.content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *commentDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.problemContent = [[commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT] isKindOfClass:[NSString class]] ? [commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT] : @"";
        self.userName = [[commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT_USERNAME] isKindOfClass:[NSString class]]
        ? [commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT_USERNAME] : @"";
        self.userSurname = [[commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT_USERSURNAME] isKindOfClass:[NSString class]] ? [commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT_USERSURNAME] :@"";
        self.date = [self dateOfComment:problem];
        self.activityTypes_Id = 5;
        self.usersID = [[problem valueForKey:ECOMAP_COMMENT_USERS_ID] isKindOfClass:[NSNumber class]] ? [[problem valueForKey:ECOMAP_COMMENT_USERS_ID] integerValue] : 0;
        self.problemsID = [[problem valueForKey:ECOMAP_COMMENT_PROBLEMS_ID] isKindOfClass:[NSNumber class]] ?[[problem valueForKey:ECOMAP_COMMENT_PROBLEMS_ID] integerValue] : 0;
    }
    return self;
}

- (NSDate *)dateOfComment:(NSDictionary *)problem
{
    NSDate *dates = nil;
    NSString *dateString = [problem valueForKey:ECOMAP_COMMENT_DATE];
    if (dateString)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
        date = [dateFormatter dateFromString:dateString];
        if (dates) return dates;
    }

    return nil;
}
@end
