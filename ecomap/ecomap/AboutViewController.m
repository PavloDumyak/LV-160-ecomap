//
//  AboutViewController.m
//  ecomap
//
//  Created by Vasyl Kotsiuba on 6/9/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AboutViewController.h"
#import "EcomapRevealViewController.h"

@interface AboutViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;

@end

#define ENGLISH_LANGUAGE_CODE @"en"
#define UKRAINIAN_LANGUAGE_CODE @"uk"
#define RUSSIAN_LANGUAGE_CODE @"ru"

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customSetup];
    [self setupAboutText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if(revealViewController)
    {
        [self.revealButtonItem setTarget:self.revealViewController];
        [self.revealButtonItem setAction:@selector(revealToggle:)];
        [self.navigationController.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        [self.navigationController.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    }
}

- (void)setupAboutText
{
    NSString *aboutText = NSLocalizedString(@"about_text", @"about text");
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:aboutText];
    
    NSRange textRange = NSMakeRange(0, [aboutText length]);
   
    //add font
    UIFont *font = [UIFont systemFontOfSize:16.0];
    UIFont *boldfont = [UIFont boldSystemFontOfSize:16.0];
    
    [attrString addAttribute:NSFontAttributeName
                       value:font
                       range:textRange];
    
    //get current language letters
    NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    //add bold
    NSRange boldRange = [aboutText rangeOfString:NSLocalizedString(@"Ecomap", nil)];
    [attrString addAttribute:NSFontAttributeName
                       value:boldfont
                       range:boldRange];
    
    NSRange firstOcured;
    
    NSString *boldText = NSLocalizedString(@"Ministry of Ecology and Natural Resources", nil);
    if ([languageCode isEqualToString:ENGLISH_LANGUAGE_CODE])
    {
        firstOcured = [aboutText rangeOfString:boldText];
        textRange = NSMakeRange(firstOcured.location + firstOcured.length, ([aboutText length] - (firstOcured.location + firstOcured.length)));
    }
    
    boldRange = [aboutText rangeOfString:boldText
                 options:0
                 range:textRange];
    
    //apply bold
    [attrString addAttribute:NSFontAttributeName
                       value:boldfont
                       range:boldRange];
    
    boldText = NSLocalizedString(@"SoftServe", nil);
    firstOcured = [aboutText rangeOfString:boldText];
    textRange = NSMakeRange(firstOcured.location + firstOcured.length, ([aboutText length] - (firstOcured.location + firstOcured.length)));
    boldRange = [aboutText rangeOfString:boldText
                                 options:0
                                   range:textRange];
    
    //aplly bold
    [attrString addAttribute:NSFontAttributeName
                       value:boldfont
                       range:boldRange];
    
    boldText = NSLocalizedString(@"WWF", nil);
    if ([languageCode isEqualToString:ENGLISH_LANGUAGE_CODE])
    {
        firstOcured = [aboutText rangeOfString:boldText];
        textRange = NSMakeRange(firstOcured.location + firstOcured.length, ([aboutText length] - (firstOcured.location + firstOcured.length)));
    }
    
    boldRange = [aboutText rangeOfString:boldText
                                 options:0
                                   range:textRange];
    
    //aplly bold
    boldText = NSLocalizedString(@"Developers:", nil);
    [attrString addAttribute:NSFontAttributeName
                       value:boldfont
                       range:boldRange];
    
    boldRange = [aboutText rangeOfString:boldText];
    
    //aplly bold
    [attrString addAttribute:NSFontAttributeName
                       value:boldfont
                       range:boldRange];
    
    
    self.aboutTextView.attributedText = attrString;
    [self.aboutTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}



@end
