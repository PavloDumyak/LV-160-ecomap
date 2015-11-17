//
//  EditProblemViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 3/17/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EditProblemViewController.h"
#import "EcomapEditableProblem.h"
#import "EcomapAdminFetcher.h"
#import "Defines.h"
#import "InfoActions.h"
#import "AFNetworking.h"
#import "ProblemViewController.h"
#import "EcomapRevisionCoreData.h"

enum : NSInteger
{
    TextFieldTag_Content = 1,
    TextFieldTag_Proposal,
};

BOOL wasUpdated = false;

@interface EditProblemViewController () <UITextViewDelegate, LoadedDifferencesProtocol>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIButton *isSolved;
@property (weak, nonatomic) IBOutlet UILabel *severity;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UITextView *proposal;

@property (strong, nonatomic) EcomapEditableProblem *editableProblem;
@property (strong, nonatomic) EcomapRevisionCoreData *revision;

@end

@implementation EditProblemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *rbb = [[UIBarButtonItem alloc] initWithTitle:@"Зберегти" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTouch:)];
    UIBarButtonItem *lbb = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTouch:)];
    [self.navigationItem setRightBarButtonItem:rbb animated:YES];
    [self.navigationItem setLeftBarButtonItem:lbb animated:YES];
    self.content.tag = TextFieldTag_Content;
    self.content.delegate = self;
    self.proposal.tag = TextFieldTag_Proposal;
    self.proposal.delegate = self;
    
    self.revision = [[EcomapRevisionCoreData alloc] init];
    self.revision.loadDelegate = self;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.editableProblem = [[EcomapEditableProblem alloc] initWithProblem:self.problem];
    [self updateUI];
}

- (void)updateUI
{
    self.titleField.text = self.editableProblem.title;
    [self.isSolved setTitle:[self stringFromIsSolved:self.editableProblem.isSolved]
                   forState:UIControlStateNormal];
    self.severity.text = [self stringFromSeverity:self.editableProblem.severity];
    self.content.text = self.editableProblem.content;
    self.proposal.text = self.editableProblem.proposal;
}

- (NSString *)stringFromIsSolved:(BOOL)isSolved
{
    if (isSolved)
    {
        return NSLocalizedString(@"вирішена", @"вирішена");
    }
    else
    {
        return NSLocalizedString(@"не вирішена", @"не вирішена");
    }
}

- (NSString *)stringFromSeverity:(NSUInteger)severity
{
    NSMutableString *severityStr = [[NSMutableString alloc] init];
    NSString *blackStars = [@"" stringByPaddingToLength:severity withString:@"★" startingAtIndex:0];
    NSString *whiteStars = [@"" stringByPaddingToLength:5-severity withString:@"☆" startingAtIndex:0];
    [severityStr appendString:blackStars];
    [severityStr appendString:whiteStars];
    return severityStr;
}



- (void)saveButtonTouch:(id)sender
{
    [self.titleField resignFirstResponder];
    [self.content resignFirstResponder];
    [self.proposal resignFirstResponder];
    [InfoActions startActivityIndicatorWithUserInteractionEnabled:NO];
    
    [EcomapFetcher editProblem:self.problem withProblem:self.editableProblem onCompletion:^(NSError *error)
    {
        if (!error)
        {
            [InfoActions stopActivityIndicator];
            [self.revision checkRevison:nil];
            wasUpdated = true;
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];

}

- (void)showDetailView
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:PROBLEMS_DETAILS_CHANGED object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:ALL_PROBLEMS_CHANGED object:self];
   
}

- (void)closeButtonTouch:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)isSolvedTap:(UIButton *)sender
{
    self.editableProblem.solved = !self.editableProblem.isSolved;
    [self.isSolved setTitle:[self stringFromIsSolved:self.editableProblem.isSolved]
                   forState:UIControlStateNormal];
}

- (IBAction)titleChanged:(UITextField *)sender
{
    self.editableProblem.title = self.titleField.text;
}

- (IBAction)addSeverityTap:(id)sender
{
    if (self.editableProblem.severity < 5)
    {
        self.editableProblem.severity++;
        self.severity.text = [self stringFromSeverity:self.editableProblem.severity];
    }
}

- (IBAction)subSeverityTap:(id)sender
{
    if (self.editableProblem.severity > 0)
    {
        self.editableProblem.severity--;
        self.severity.text = [self stringFromSeverity:self.editableProblem.severity];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    switch (textView.tag)
    {
        case TextFieldTag_Content:
            self.editableProblem.content = textView.text;
            break;
        case TextFieldTag_Proposal:
            self.editableProblem.proposal = textView.text;
            break;
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
