//
//  Header.h
//  EcomapFetcher
//
//  Created by Vasya on 2/1/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//
#ifndef EcomapFetcher_Header_h
#define EcomapFetcher_Header_h

//API address1 
#define ECOMAP_ADDRESS @"http://176.36.11.25:8000/"
//#define ECOMAP_ADDRESS @"http://localhost:8090/"
//#define ECOMAP_ADDRESS @"http://ecomap.org/"
//#define ECOMAP_ADDRESS @"http://192.168.2.1:8090/"
//eded
#define ECOMAP_API @"api/"
#define ECOMAP_GET_PROBLEMS_API @"allproblems"
#define ECOMAP_GET_PROBLEMS_WITH_ID_API @"problems/"
#define ECOMAP_GET_PROBLEM_API @"problems"
#define ECOMAP_GET_PROBLEM_TYPES @"problems"
#define ECOMAP_POST_LOGIN_API @"login"
#define ECOMAP_POST_TOKEN_REGISTRATION @"registerToken/"
#define ECOMAP_GET_LOGOUT_API @"logout"
#define ECOMAP_POST_REGISTER_API @"register"
#define ECOMAP_POST_CHANGEPASSWORD_API @"changePassword/"
#define ECOMAP_GET_LARGE_PHOTOS_ADDRESS @"photos/large/"
#define ECOMAP_GET_SMALL_PHOTOS_ADDRESS @"photos/small/"
#define ECOMAP_POST_PROBLEM @"allproblems"
#define ECOMAP_GET_RESOURCES @"pages"
#define ECOMAP_GET_ALIAS @"pages/"
#define ECOMAP_POST_VOTE @"vote"
#define ECOMAP_POST_COMMENT @"comment/"
#define ECOMAP_POST_PHOTO @"photo/"

#define ECOMAP_PROBLEM_ADDRESS_WITH_ID @"http://176.36.11.25:8000/api/problems/"
#define ECOMAP_PROBLEM_POST_ADDRESS @"http://176.36.11.25:8000/api/problems"
#define ECOMAP_REVISION @"problems?rev="

#define ECOMAP_ADDRESS_FOR_REVISON @"http://176.36.11.25:8000/api/problems?rev="
#define ECOMAP_CHANGE_COMMENTS @"comments/"
//Queries for statistics
#define ECOMAP_GET_TOP_CHARTS_OF_PROBLEMS @"getStats4"
#define ECOMAP_GET_GENERAL_STATS @"getStats3"
#define ECOMAP_GET_STATS_FOR_ALL_THE_TIME @"getStats2/A"
#define ECOMAP_GET_STATS_FOR_LAST_YEAR @"getStats2/Y"
#define ECOMAP_GET_STATS_FOR_LAST_MOTH @"getStats2/M"
#define ECOMAP_GET_STATS_FOR_LAST_WEEK @"getStats2/W"
#define ECOMAP_GET_STATS_FOR_LAST_DAY @"getStats2/D"

// Queries for admin's API
#define ECOMAP_ADD_COMMENT @"/comments"
#define ECOMAP_PUT_EDIT_PROBLEM @"editProblem/"
#define ECOMAP_DELETING_COMMENT @"comments/"
//Problems types descripton
#define ECOMAP_PROBLEM_TYPES_ARRAY @[NSLocalizedString(@"Проблеми лісів", @"Forest problems"), NSLocalizedString(@"Сміттєзвалища", @"Landfills"), NSLocalizedString(@"Незаконна забудова", @"Illegal construction"), NSLocalizedString(@"Проблеми водойм", @"Ponds problems"), NSLocalizedString(@"Загрози біорізноманіттю",@"Threats to biodiversity"), NSLocalizedString(@"Браконьєрство", @"Poaching"), NSLocalizedString(@"Інші проблеми", @"Other problems")]

//Paths to Ecomap problem details array
#define ECOMAP_PROBLEM_DETAILS_DESCRIPTION 0
#define ECOMAP_PROBLEM_DETAILS_PHOTOS 1
#define ECOMAP_PROBLEM_DETAILS_COMMENTS 2

// keys (paths) applicable to all types of Ecomap problems dictionaries
//#define ECOMAP_PROBLEM_ID @"Id"
#define ECOMAP_PROBLEM_ID @"id"

//#define ECOMAP_PROBLEM_TITLE @"Title"
#define ECOMAP_PROBLEM_TITLE @"title"

#define ECOMAP_PROBLEM_LATITUDE @"latitude"
#define ECOMAP_PROBLEM_LONGITUDE @"longitude"

//#define ECOMAP_PROBLEM_TYPE_ID @"ProblemTypes_Id"
#define ECOMAP_PROBLEM_TYPE_ID @"problem_type_id"

#define ECOMAP_PROBLEM_STATUS @"status"

// keys (paths) to values in a PROBLEM dictionary of PROBLEMS array
#define ECOMAP_PROBLEM_DATE @"datetime"

// keys (paths) to values in a FIRST dictionary (details about problem) in PROBLEM array
#define ECOMAP_PROBLEM_CONTENT @"content"
#define ECOMAP_PROBLEM_PROPOSAL @"proposal"
#define ECOMAP_PROBLEM_SEVERITY @"severity"
#define ECOMAP_PROBLEM_MODERATION @"moderation"
#define ECOMAP_PROBLEM_VOTES @"number_of_votes"
#define ECOMAP_PROBLEM_VALUE @"value"

// keys (paths) applicable to all types of Ecomap resources
#define ECOMAP_RESOURCE_TITLE @"title"
#define ECOMAP_RESOURCE_ALIAS @"alias"
#define ECOMAP_RESOURCE_ID @"id"
#define ECOMAP_RESOURCE_ISRESOURCE @"is_resource"

// keys (paths) applicable to some type of  ecomap.org/resources/alias
#define ECOMAP_RESOURCE_ALIAS_CONTENT @"content"

// keys (paths) to values in a SECOND dictionary (photos of a problem) in PROBLEM array
#define ECOMAP_PHOTO_ID @"Id"
#define ECOMAP_PHOTO_LINK @"Link"
#define ECOMAP_PHOTO_STATUS @"Status"
#define ECOMAP_PHOTO_DESCRIPTION @"Description"
#define ECOMAP_PHOTO_PROBLEMS_ID @"Problems_Id"
#define ECOMAP_PHOTO_USERS_ID @"Users_Id"

// keys (paths) to values in a THIRD dictionary (comments to problems) in PROBLEM array
#define ECOMAP_COMMENT_ID @"id"
#define ECOMAP_COMMENT_CONTENT @"content"
#define ECOMAP_COMMENT_DATE @"created_date"
#define ECOMAP_COMMENT_ACTYVITYTYPES_ID @"activitytypes_id"
#define ECOMAP_COMMENT_USERS_ID @"created_by"
#define ECOMAP_COMMENT_PROBLEMS_ID @"problems_id"

//keys (paths) to value in a content dictionary of a THIRD dictionary

/*"first_name" = Pablo;
"last_name" = Pablo;
"user_id" = 220;
"user_perms" =*/

#define ECOMAP_COMMENT_CONTENT_CONTENT @"Content"
#define ECOMAP_COMMENT_CONTENT_USERNAME @"userName"
#define ECOMAP_COMMENT_CONTENT_USERSURNAME @"userSurname"

// keys (paths) to values in a USER dictionary
#define ECOMAP_USER_ID @"user_id"
#define ECOMAP_USER_NAME @"first_name"
#define ECOMAP_USER_SURNAME @"last_name"
#define ECOMAP_USER_ROLE @"user_roles"
#define ECOMAP_USER_ITA @"iat"
#define ECOMAP_USER_TOKEN @"token"
#define ECOMAP_USER_EMAIL @"email"
#define ECOMAP_USER_DELETE_PROBLEM @"Delete_problem"

// keys (paths) to values in a STAT dictionary in GENERAL STATS array
#define ECOMAP_GENERAL_STATS_PROBLEMS @"problems"
#define ECOMAP_GENERAL_STATS_VOTES @"votes"      // "number_of_votes"?
#define ECOMAP_GENERAL_STATS_PHOTOS @"photos"
#define ECOMAP_GENERAL_STATS_COMMENTS @"comments"

#define NO_INTERNET_CODE 666

#endif
