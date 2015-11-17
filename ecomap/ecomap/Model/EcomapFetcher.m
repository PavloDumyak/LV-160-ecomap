//
//  EcomapFetcher.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapFetcher.h"
#import "EcomapLocalPhoto.h"
#import "InfoActions.h"
#import "AFNetworking.h"
#import "EcomapCoreDataControlPanel.h"
#import "AppDelegate.h"
#import "EcomapRevisionCoreData.h"
#import "AppDelegate.h"

@implementation EcomapFetcher

+ (void)loadEverything
{
    EcomapCoreDataControlPanel *coreDataClass = [EcomapCoreDataControlPanel sharedInstance];
    NSString *status = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstdownload"];
    
    if (![status isEqualToString:@"complete"])
    {
        [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error)
         {
             [coreDataClass setAllProblems:problems];
             
             [EcomapFetcher loadAllProblemsDescription:^(NSArray *problems, NSError *error)
              {
                  [coreDataClass setDescr:problems];
                  [coreDataClass addProblemIntoCoreData];
              }];
         }];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"complete" forKey:@"firstdownload"];
    }
    
    [EcomapFetcher loadResourcesOnCompletion:^(NSArray *resources, NSError *error)      //class method from ecomapFetcher
     {
         if (error)
         {
             DDLogVerbose(@"ERROR");
         }
         for (EcomapResources *object in resources)
         {
             [EcomapFetcher loadAliasOnCompletion:^(NSArray *alias, NSError *error) {
                 if (error)
                 {
                     DDLogVerbose(@"Error");
                 }
                 
             } String:[NSString stringWithFormat:@"%ld", object.resId]];
         }
     }
     ];
    
    [self getProblemWithComments];
    [self updateData];
    [self keepRevision];
}

+ (void)keepRevision
{
    EcomapRevisionCoreData *ob = [[EcomapRevisionCoreData alloc] init];
    
    [ob checkRevison: nil];
    [self getProblemWithComments];
    
}

+ (void)updateData
{    
    [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(keepRevision) userInfo:nil repeats:YES];
}

#pragma mark -- get revision

+(void)checkRevision:(void (^)(BOOL differance, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforRevison]]
              sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                 completionHandler:^(NSData *JSON, NSError *error) {
                     BOOL revision = NO;
                     if (!error) {
                         if (JSON) {
                             NSDictionary *aJSON = [JSONParser parseJSONtoDictionary:JSON];
                             NSNumber *revisionLocal = [[NSUserDefaults standardUserDefaults] valueForKey:@"revision"];
                             [[NSUserDefaults standardUserDefaults] setObject:revisionLocal forKey:@"oldrevision"];
                             NSNumber *recieveRevison = [aJSON valueForKey:@"current_activity_revision"];
                             if([recieveRevison isEqual:revisionLocal])
                             {
                                 revision = NO;
                             }
                             else
                             {
                                
                                 [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"revision"];
                                 [[NSUserDefaults standardUserDefaults]setObject:recieveRevison forKey:@"revision"];
                                 revision = YES;
                             }
                         }
                     }
                     completionHandler(revision, error);
                 }];
}



+(void)loadProblemsDifference:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    NSMutableString *urlForLoadDifferance = [NSMutableString stringWithFormat:ECOMAP_ADDRESS_FOR_REVISON];
    NSString *tmprevision = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"revision"]];
    NSString *oldrevision = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"oldrevision"]];
    
    
    if(oldrevision == nil)
    {
         [urlForLoadDifferance appendString:tmprevision];
    }
    else
    {
         [urlForLoadDifferance appendString:oldrevision];
    }
    
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlForLoadDifferance]]
              sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                 completionHandler:^(NSData *JSON, NSError *error) {
                     NSArray *problems = nil;
                     if (!error) {
                         //Extract received data
                         if (JSON)
                         {
                            NSDictionary *aJSON = [JSONParser parseJSONtoDictionary:JSON];
                            problems = [aJSON[@"data"] isKindOfClass:[NSArray class]] ? aJSON[@"data"] : nil;
                         }
                     } else [InfoActions showAlertOfError:error];
                     completionHandler(problems, error);
                 }];
}






#pragma mark - Get all Problems


+(void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
              sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                 completionHandler:^(NSData *JSON, NSError *error) {
                     NSMutableArray *problems = nil;
                     NSArray *problemsFromJSON = nil;
                     
                     if (!error)
                     {
                         //Extract received data
                         if (JSON)
                         {
                             DDLogVerbose(@"All problems loaded success from ecomap server");
                             //Parse JSON
                             NSDictionary *aJSON = [JSONParser parseJSONtoDictionary:JSON];
                             NSNumber *revision =  [aJSON valueForKey:@"current_activity_revision"];
                             problemsFromJSON = [aJSON[@"data"] isKindOfClass:[NSArray class]] ? aJSON[@"data"] : nil;
                             [[NSUserDefaults standardUserDefaults] setObject:revision forKey:@"revision"];
                             //NSNumber *num = [[NSUserDefaults standardUserDefaults] valueForKey:@"revision"];
                             //Fill problems array
                             if (problemsFromJSON)
                             {
                                 problems = [NSMutableArray array];
                                 //Fill array with EcomapProblem
                                 for (NSDictionary *problem in problemsFromJSON)
                                 {
                                     EcomapProblem *ecoProblem = [[EcomapProblem alloc] initWithProblem:problem];
                                     [problems addObject:ecoProblem];
                                 }
                             }
                             
                         }
                     } //else [InfoActions showAlertOfError:error];

                     completionHandler(problems, error);
                 }];
    
}


+(void)loadAllProblemsDescription:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher ProblemDescription]]
              sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                 completionHandler:^(NSData *JSON, NSError *error) {
                     NSMutableArray *problems = nil;
                     NSArray *problemsFromJSON = nil;
                     if (!error)
                     {
                         //Extract received data
                         if (JSON)
                         {
                             DDLogVerbose(@"All problems loaded success from ecomap server");
                             //Parse JSON
                             NSDictionary *aJSON = [JSONParser parseJSONtoDictionary:JSON];
                             problemsFromJSON = [aJSON[@"data"] isKindOfClass:[NSArray class]] ? aJSON[@"data"] : nil;
                             
                             //Fill problems array
                             if (problemsFromJSON)
                             {
                                 problems = [NSMutableArray array];
                                 //Fill array with EcomapProblem
                                 for (NSDictionary *problem in problemsFromJSON)
                                 {
                                     EcomapProblemDetails *ecoProblem = [[EcomapProblemDetails alloc] initWithProblem:problem];
                                     [problems addObject:ecoProblem];
                                 }
                             }
                             
                         }
                     }
                     //else [InfoActions showAlertOfError:error];
                     
                     //set up completionHandler
                     completionHandler(problems, error);
                 }];
    
}


#pragma mark - Post comment
+(void)createComment:(NSString*)userId andName:(NSString*)name
          andSurname:(NSString*)surname andContent:(NSString*)content andProblemId:(NSString*)probId
        OnCompletion:(void (^)(EcomapCommentaries *obj,NSError *error))completionHandler
{
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforComments:probId]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    NSLog(@"%@;%@;%@",userId,name,surname);
    //Create JSON data for send to server
    NSDictionary *commentData = @{@"data": @{@"userId":userId,@"userName":name, @"userSurname":surname, @"Content":content} };
    NSLog(@"%@",commentData);
    NSData *data = [NSJSONSerialization dataWithJSONObject:commentData options:0 error:nil];
    [DataTasks uploadDataTaskWithRequest:request fromData:data
                    sessionConfiguration:sessionConfiguration
                       completionHandler:^(NSData *JSON, NSError *error) {
                           NSDictionary *commentsInfo;
                           // EcomapLoggedUser * check = [[EcomapLoggedUser alloc]init];
                           EcomapCommentaries * difComment = nil;
                           
                           if(!error)
                               
                           {    difComment = [[EcomapCommentaries alloc]initWithInfo:commentsInfo];
                               if([EcomapLoggedUser currentLoggedUser])
                               {
                                   
                                   //commentsInfo = [JSONParser parseJSONtoDictionary:JSON];
                                   
                                   
                               }
                               else
                                   difComment = nil;
                               
                           } else [InfoActions showAlertOfError:error];
                           
                           completionHandler(difComment,error);
                           
                           
                           
                       }];
    
}



#pragma mark - load all allias content

+(void)loadAliasOnCompletion:(void (^)(NSArray *alias, NSError *error))completionHandler String:(NSString *)str
{
    
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAlias:str]]
              sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                 completionHandler:^(NSData *JSON, NSError *error) {
                     DDLogVerbose(@"%@",str);
                     
                     NSMutableArray *aliases = [NSMutableArray array];
                     
                     if(!error)
                     {
                         id value = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                         if ([value isKindOfClass:[NSArray class]])
                         {
                             NSArray *aliasFromJSON = (NSArray*)value;
                             
                             //Fill array with ECOMAPRESOURCES
                             for (NSDictionary *singleAlias in aliasFromJSON)
                             {
                                 EcomapAlias *ecoAl = [[EcomapAlias alloc] initWithAlias:singleAlias];
                                 [aliases addObject:ecoAl];
                             }
                         }
                         else if ([value isKindOfClass:[NSDictionary class]])
                         {
                             EcomapAlias *ecoAl = [[EcomapAlias alloc] initWithAlias:value];
                             [aliases addObject:ecoAl];
                             
                             EcomapCoreDataControlPanel *resourcesIntoCD = [EcomapCoreDataControlPanel sharedInstance];
                             resourcesIntoCD.resourceContent = ecoAl.content;
                             
                             NSNumberFormatter *formatOfNumber = [[NSNumberFormatter alloc] init];
                             formatOfNumber.numberStyle = NSNumberFormatterDecimalStyle;
                             NSNumber *resourceID = [formatOfNumber numberFromString:str];
                             
                             [resourcesIntoCD addContentToResource:resourceID];
                         }
                     }
                     completionHandler(aliases, error);
                     
                 }];
}

#pragma mark - Load all Resources

+(void)loadResourcesOnCompletion:(void (^)(NSArray *resources, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforResources]]
              sessionConfiguration:[NSURLSessionConfiguration  ephemeralSessionConfiguration]
                 completionHandler:^(NSData *JSON, NSError *error) {
                     
                     NSMutableArray *resources = nil;
                     NSArray *resourcesFromJSON = nil;
                     if(!error)
                     {
                         //Parse JSON
                         resourcesFromJSON = (NSArray*)[NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                         resources = [NSMutableArray array];
                         
                         //Fill array with ECOMAPRESOURCES
                         for(NSDictionary *resource in resourcesFromJSON)
                         {
                             EcomapResources *ecoRes = [[EcomapResources alloc] initWithResource:resource];
                             [resources addObject:ecoRes];
                         }
                     }
                     
                     completionHandler(resources,error);
                     
                     NSManagedObjectContext* context = [AppDelegate sharedAppDelegate].managedObjectContext;
                     NSFetchRequest *request = [[NSFetchRequest alloc] init];
                     NSEntityDescription *description = [NSEntityDescription entityForName:@"Resource" inManagedObjectContext:context];
                     
                     [request setEntity:description];
                     NSError *requestError = nil;
                     NSArray *coredataResources = [context executeFetchRequest:request error:&requestError];
                     
                     NSMutableArray *resourcesToAddIntoCD = [[NSMutableArray alloc] init];
                     
                     for (EcomapResources *resource in resources)
                     {
                         BOOL resourceExistsInCD = NO;
                         
                         for (Resource *coreDataResource in coredataResources)
                         {
                             NSInteger resourceId = [coreDataResource.resourceID integerValue];
                             if (resource.resId == resourceId)
                             {
                                 resourceExistsInCD = YES;
                                 break;
                             }
                         }
                         
                         if (!resourceExistsInCD)
                         {
                             [resourcesToAddIntoCD addObject:resource];
                         }
                     }
                     
                     EcomapCoreDataControlPanel *resourcesIntoCD = [EcomapCoreDataControlPanel sharedInstance];
                     [resourcesIntoCD addResourceIntoCD:resourcesToAddIntoCD];
                 }];
}


+(BOOL)updateComments:(NSUInteger)problemID controller:(AddCommViewController*)controller
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString* baseUrl = ECOMAP_PROBLEM_ADDRESS_WITH_ID;
    NSString* middleUrl = [baseUrl stringByAppendingFormat:@"%lu",(unsigned long)problemID];
    NSString* finalUrl = [middleUrl stringByAppendingString:@"/comments"];
    
    [manager GET:finalUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray* tmp = [responseObject valueForKey:@"data"];
         NSLog(@"%@", [tmp valueForKey:@"id"]);
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmp options:NSJSONWritingPrettyPrinted error:nil];
         NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
         NSArray *ar = [JSONParser parseJSONtoArray:objectData];
         EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
         [ob setCommentariesArray:ar :problemID];
         ob.problemsID = problemID;
         [controller reload];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
         ob.problemsID = problemID;
         [ob setCommentariesArray:nil :problemID];
         [controller reload];
         NSLog(@"%@",error);
         
     }];
    return YES;
}


#pragma mark - Load comments


+ (void)getProblemWithComments
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    
    // 1. Load problem ids which contain comments
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Problem" inManagedObjectContext:context];
    [request setEntity:description];
    [request setResultType:NSDictionaryResultType];
    request.predicate = [NSPredicate predicateWithFormat:@"numberOfComments > %d", 0];
    NSError *requestError = nil;
    NSArray *requestArray = [context executeFetchRequest:request error:&requestError];
    
    NSArray *problemIDsWithComments = [requestArray valueForKey:@"idProblem"];
    
    NSLog(@"Array of problems from CoreData %@", problemIDsWithComments);
    
    // 2. Load & save comments
    
    for (id problemID in problemIDsWithComments)
    {
        NSInteger idProblem = [problemID integerValue];
        [self loadCommentsFromWeb:(NSUInteger)idProblem];
    }
    
    // 3. Log results
    
    EcomapCoreDataControlPanel *allComments = [EcomapCoreDataControlPanel sharedInstance];
    [allComments logCommentsFromCoreData];
}


+ (void)loadCommentsFromWeb:(NSUInteger)problemID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString* baseUrl = ECOMAP_PROBLEM_ADDRESS_WITH_ID;
    NSString* middleUrl = [baseUrl stringByAppendingFormat:@"%lu",(unsigned long)problemID];
    NSString* finalUrl = [middleUrl stringByAppendingString:@"/comments"];
    [manager GET:finalUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSArray* tmp = [responseObject valueForKey:@"data"];
        NSLog(@"%@", [tmp valueForKey:@"id"]);
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmp options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray *comments = [JSONParser parseJSONtoArray:objectData];
        EcomapCoreDataControlPanel *commentsIntoCoreData = [EcomapCoreDataControlPanel sharedInstance];
        [commentsIntoCoreData addCommentsIntoCoreData:problemID comments:comments];
        
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"%@",error);
    }];    
}




#pragma mark - Get Problem with ID
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler
{

    [self loadCommentsFromWeb:problemID];
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforProblemWithID:problemID]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSArray *photos = nil;
                    NSArray *comments = nil;
                    EcomapProblemDetails *problemDetails = nil;
                    NSMutableArray *problemPhotos = nil;
                    NSMutableArray *problemComments = nil;
                  
                    if (!error) {
                        //Extract received data
                        if (JSON) {
                            //Check if we have a problem with such problemID.
                            //If there is no one, server give us back Dictionary with "error" key
                            //Parse JSON
                            NSDictionary *answerFromServer = [JSONParser parseJSONtoDictionary:JSON];

                            problemDetails = [[EcomapProblemDetails alloc] initWithProblem:answerFromServer];
                           
                            DDLogVerbose(@"Problem (id = %lu) loaded success from ecomap server", (unsigned long)problemDetails.problemID);
                            
                           // photos = [jsonArray objectAtIndex:ECOMAP_PROBLEM_DETAILS_PHOTOS];
                            problemPhotos = [NSMutableArray array];
                            for(NSDictionary *photo in photos){
                                id ecoPhoto = [[EcomapPhoto alloc] initWithInfo:photo];
                                if(photo)
                                    [problemPhotos addObject:ecoPhoto];
                            }
                            // DUMYAK CHANGE THERE
                            
                        //    comments = [jsonArray objectAtIndex:ECOMAP_PROBLEM_DETAILS_COMMENTS];
                            problemComments = [NSMutableArray array];
                            for(NSDictionary *comment in comments){
                                id ecoComment = [[EcomapActivity alloc] initWithInfo:comment];
                                if(ecoComment)
                                    [problemComments addObject:ecoComment];
                            }
                            problemDetails.photos = problemPhotos;
                            problemDetails.comments = problemComments;
                        }
                    } else [InfoActions showAlertOfError:error];
                    
                    //Return problemDetails
                    completionHandler(problemDetails, error);
                }];
    
}


#pragma mark - Statistics Fetching


#pragma mark -
+ (void)addVoteForProblem:(EcomapProblemDetails *)problemDetails withUser:(EcomapLoggedUser *)user OnCompletion:(void (^)(NSError *error))completionHandler
{
    if(![problemDetails canVote:user])             
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:NSLocalizedString(@"Будь ласка, увійдіть до системи для голосування", @"Please, login to vote!")
                                                      delegate:nil cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [alert show];
        return;        
    }
    
    NSDictionary *voteData = nil;
    if(user)
    {
        voteData = @{
                     @"idProblem":@(problemDetails.problemID),
                     @"userId":@(user.userID),
                     @"userName":user.name ? user.name : @"",
                     @"userSurname":user.surname ? user.surname : @""
                     };
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        EcomapCommentaries *ob = [EcomapCommentaries sharedInstance];
        [[NetworkActivityIndicator sharedManager] startActivity];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        [manager setRequestSerializer:jsonRequestSerializer];
        NSString *baseUrl = ECOMAP_ADDRESS;
        baseUrl = [baseUrl stringByAppendingString:ECOMAP_API];
        baseUrl = [baseUrl stringByAppendingString:ECOMAP_GET_PROBLEMS_WITH_ID_API];
        NSString *middle = [baseUrl stringByAppendingFormat:@"%lu/",(unsigned long)[ob problemsID]];
        NSString *final = [middle stringByAppendingString:ECOMAP_POST_VOTE];
        
        [manager POST:final parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSLog(@"vote is added");            
          
            if (completionHandler)
            {
                completionHandler(nil);
            }
        }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if (completionHandler)
            {
                completionHandler(error);
            }
        }];
        
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NetworkActivityIndicator sharedManager]endActivity];
    });
    
   }

+ (void)registerToken:(NSString *)token
         OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler {
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforTokenRegistration]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"token" : token};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:0
                                                     error:nil];
    [DataTasks uploadDataTaskWithRequest:request
                                fromData:data
                    sessionConfiguration:sessionConfiguration
                       completionHandler:^(NSData *JSON, NSError *error) {
                           NSDictionary *jsonString = [JSONParser parseJSONtoDictionary:JSON];
                           completionHandler([jsonString valueForKey:@"err"], error);
                       }];
    
}

+ (void)addCommentToProblem:(NSInteger)problemID withContent:(NSString *)content
               onCompletion:(void (^)(NSError *error))completionHandler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
    [manager setRequestSerializer:jsonRequestSerializer];
    NSDictionary *cont = @{ @"content":content };
    
    [manager POST:[EcomapURLFetcher URLforAddComment:problemID] parameters:cont success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completionHandler(nil);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error by adding new comment: %@",error);
         completionHandler(error);
     }];

}

+ (void)deleteComment:(NSInteger)commentID onCompletion:(void (^)(NSError *error))completionHandler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
    [manager setRequestSerializer:jsonRequestSerializer];
    
    [manager DELETE:[EcomapURLFetcher URLforChangeComment:commentID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completionHandler(nil);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error by deleting comment: %@",error);
         completionHandler(error);
     }];
}

+ (void)editComment:(NSInteger)commentID withContent:(NSString *)content
       onCompletion:(void (^)(NSError *error))completionHandler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *dictionary = @{
                                 @"content" : content,
                                 };
    
    [manager PUT:[EcomapURLFetcher URLforChangeComment:commentID] parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completionHandler(nil);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error by editing comment: %@",error);
         completionHandler(error);
     }];
    
}

+ (void)editProblem:(EcomapProblemDetails *)problem
        withProblem:(EcomapEditableProblem *)editableProblem
       onCompletion:(void (^)(NSError *error))completionHandler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *dictionary = @{
                                 @"status" : [self stringFromIsSolvedForRequest:editableProblem.isSolved],
                                 @"problem_type_id" : @(problem.problemTypesID),
                                 @"severity" : [NSString stringWithFormat:@"%lu", editableProblem.severity],
                                 @"title" : editableProblem.title,
                                 @"longitude" : @(problem.longitude),
                                 @"content" : editableProblem.content,
                                 @"latitude" : @(problem.latitude),
                                 @"proposal" : editableProblem.proposal
                                 };
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager PUT:[EcomapURLFetcher URLforEditingProblem:problem.problemID] parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completionHandler(nil);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error by editing problem: %@",error);
         completionHandler(error);
     }];

}

+ (NSString *)stringFromIsSolvedForRequest:(BOOL)isSolved
{
    return (isSolved)? @"SOLVED" : @"UNSOLVED";
}

+ (void)deleteProblem:(NSUInteger)problemID
         onCompletion:(void (^)(NSError *error))completionHandler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
    [manager setRequestSerializer:jsonRequestSerializer];
    
    [manager DELETE:[EcomapURLFetcher URLforEditingProblem:problemID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        completionHandler(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error by deleting problem: %@",error);
        completionHandler(error);
    }];
}


@end
