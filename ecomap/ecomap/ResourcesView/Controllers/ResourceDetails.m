
//  ResourceDetails.m
//  ecomap
//
//  Created by Mikhail on 2/4/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ResourceDetails.h"

@interface ResourceDetails ()


@end

@implementation ResourceDetails

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.spiner startAnimating];
    [self putData];
}

- (void) putData
{
    UIFont *font = [UIFont systemFontOfSize:21];  //     FOR FONT @"helvetica"
    NSString *bodyHTML = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body {font-family: \"%@\"; font-size: %f;}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>%@</body> \n"
                                   "</html>", font.familyName, [UIFont systemFontSize], self.details];
    
    NSString *haystack = bodyHTML;
    NSString *prefix = @"<p><img class=\"ta-insert-video\" ta-insert-video=\""; // string prefix, not needle prefix!
    NSString *suffix = @"\" src=\"\" allowfullscreen=\"true\" width=\"300\" frameborder=\"0\" height=\"250\"/></p>"; // string suffix, not needle suffix!
    NSRange prefixRange = [haystack rangeOfString:prefix];
    if (prefixRange.length > 0) {
        NSRange suffixRange = [[haystack substringFromIndex:prefixRange.location+prefixRange.length] rangeOfString:suffix];
        NSRange needleRange = NSMakeRange(prefixRange.location+prefix.length, suffixRange.location);
        NSString *url = [haystack substringWithRange:needleRange];
        NSString *bodyBegin = [haystack substringWithRange:NSMakeRange(0, prefixRange.location)];
        NSString *bodyEnd = [haystack substringWithRange:NSMakeRange(prefixRange.location+prefixRange.length+url.length+suffixRange.length, haystack.length - (prefixRange.location+prefixRange.length+url.length+suffixRange.length)) ];
        bodyHTML = [NSString stringWithFormat:@"%@ <iframe width='%f' height='315' src='%@' frameborder='0' allowfullscreen></iframe>%@", bodyBegin,     [[UIScreen mainScreen] bounds].size.width-20,url, bodyEnd];
    }
    [self.myWebView loadHTMLString:bodyHTML baseURL:nil];    //load html to WEBVIEW
    [self.spiner setHidden:YES];
}

-(NSString *)details
{
    if (!_details)
    {
        _details=[[NSString alloc]init];
    }
    return _details;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
