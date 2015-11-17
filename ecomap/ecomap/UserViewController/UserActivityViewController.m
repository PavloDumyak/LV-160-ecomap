//
//  UserActivityViewController.m
//  ecomap
//
//  Created by Vasya on 3/1/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "UserActivityViewController.h"
#import "EcomapLoggedUser.h"
#import "InfoActions.h"

@interface UserActivityViewController ()
@property (nonatomic) CGFloat keyboardHeight;
@end

@implementation UserActivityViewController

#pragma mark - view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpinside:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    //Buttons images localozation
    UIImage *loginWithFacebookButtonImage = [UIImage imageNamed:NSLocalizedString(@"FacebookLogButtonURK", @"Facebook button image")];
    UIImage *separatorImg = [UIImage imageNamed:NSLocalizedString(@"SeparatorURK", @"Separator image")];
    UIImage *loginButtonImage = [UIImage imageNamed:NSLocalizedString(@"LogInButtonURK", @"Login button button image")];
    UIImage *registerButtonImage = [UIImage imageNamed:NSLocalizedString(@"RegisterButtonURK", @"Register comment button image")];
    UIImage *changePasswordButtonImage = [UIImage imageNamed:NSLocalizedString(@"ChangePasswordButtonURK", @"Change pass button button image")];
    UIImage *logoutButtonImage = [UIImage imageNamed:NSLocalizedString(@"LogoutButtonURK", @"Logout button button image")];

    [self.loginWithFacebookButton setImage:loginWithFacebookButtonImage
                                  forState:UIControlStateNormal];
    [self.separatorImage setImage:separatorImg];
    [self.loginButton setImage:loginButtonImage
                      forState:UIControlStateNormal];
    [self.registerButton setImage:registerButtonImage
                         forState:UIControlStateNormal];
    [self.changePasswordButton setImage:changePasswordButtonImage
                               forState:UIControlStateNormal];
    [self.logoutButton setImage:logoutButtonImage
                       forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //setup keyboard notifications
    [self registerForKeyboardNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.activeField resignFirstResponder];
    [self deregisterForKeyboardNotifications];
}
#pragma mark - accessors
-(UITextField *)textFieldToScrollUPWhenKeyboadAppears
{
    return self.activeField;
}

#pragma mark - keyborad managment
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)deregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent
// To manage keyboard appearance (situation when keyboard cover active textField)
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardHeight = keyboardSize.height;
    //Increase scroll view contetn size by keyboard size
    CGRect contetntViewRect = self.activeField.superview.superview.frame;
    contetntViewRect.size.height += keyboardSize.height;
    self.scrollView.contentSize = contetntViewRect.size;
    
    // If current "textFieldToScrollUPWhenKeyboadAppears" is hidden by keyboard, scroll it so it's visible
    [self ifHiddenByKeyboarScrollUPTextField:self.textFieldToScrollUPWhenKeyboadAppears];
}

- (void)ifHiddenByKeyboarScrollUPTextField:(UITextField *)textFied
{
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= self.keyboardHeight;
    
    CGFloat textFieldHieght = textFied.frame.size.height;
    CGPoint textFieldLeftBottomPoint = [self.view convertPoint:CGPointMake(textFied.frame.origin.x, (textFied.frame.origin.y + textFieldHieght))
                                                        fromView:textFied.superview];
    
    if (!CGRectContainsPoint(visibleRect, textFieldLeftBottomPoint) )
    {
        [self.scrollView setContentOffset:CGPointMake(0.0, self.scrollView.contentOffset.y + textFieldLeftBottomPoint.y - visibleRect.size.height + KEYBOARD_TO_TEXTFIELD_SPACE) animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification  *)aNotification
{
    //Reset scroll view contetn size by storyboard contentView size
    self.scrollView.contentSize = self.activeField.superview.superview.frame.size;
}

//Manage tap gesture
- (void)touchUpinside:(UITapGestureRecognizer *)sender
{
    [self.activeField resignFirstResponder];
}

#pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    //Set target action fot textField
    [self.activeField addTarget:self
                         action:@selector(editingChanged:)
               forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField //Abstract
{
    return YES;
}

//Check active text field (every time character is enetered) to set checkmark
-(void)editingChanged:(UITextField *)textField
{
    //consider "taxtField.tag" value is equal to appropriative checkmarkType value
    if ((textField.tag == checkmarkTypeEmail && [self isValidMail:textField.text]) ||  //validation for email
        (textField.tag == checkmarkTypeNewPassword && [self isPasswordsEqual]) || //validation for passwords (newPassword and confirdPasswor)
        ([self isTypeOfSimpleTextOfTextField:textField] && ![textField.text isEqualToString:@""]))
    {
        //validation for name, surname, oldPassword
        [self showCheckmarks:@[[NSNumber numberWithInt:textField.tag]] withImage:CHECKMARK_GOOD_IMAGE];
    }
    else
    {
        [self showCheckmarks:@[[NSNumber numberWithInt:textField.tag]] withImage:CHECKMARK_BAD_IMAGE];
    }
}

#pragma mark - helper methods
- (BOOL)canSendRequest
{
    //BOOL result = YES;
    //Check if fields are empty
    if ([self isAnyTextFieldEmpty])
    {
        [InfoActions showAlertOfError:NSLocalizedString(@"\nБудь-ласка заповніть усі поля", @"Please, fill all fields")];
        return NO;
    }
    else if (self.emailTextField && ![self isValidMail:self.emailTextField.text])
    {
        //check if email is valid
        [InfoActions showAlertOfError:NSLocalizedString(@"\nБудь-ласка введіть дійсну email-адресу", @"Bad e-mail")];
        return NO;
    }
    else if (self.confirmPasswordTextField && ![self isPasswordsEqual]) //check if passwords are equal
    {
        [InfoActions showAlertOfError:NSLocalizedString(@"\nВведені паролі не співпадають", @"Passwords are not equal")];
        return NO;
    }
    
    return YES;
}

- (BOOL)isValidMail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    //Uncomment on release
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    //NSString *laxString = @".+@+.+[A-Za-z]{2,4}";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

//compare NewPasswordField and confirmPasswordField
- (BOOL)isPasswordsEqual
{
    BOOL equal = NO;
    if ([self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text] && ![self.passwordTextField.text isEqualToString:@""])
    {
        equal = YES;
    }
    return equal;
}

//Consider name, surname and password field are "simple text" text fields (because the only validation for them is not to be empty field)
- (BOOL)isTypeOfSimpleTextOfTextField:(UITextField *)textField
{
    BOOL simple = NO;
    if (textField.tag == checkmarkTypeName || textField.tag == checkmarkTypeSurname || textField.tag == checkmarkTypePassword)
    {
        simple = YES;
    }
    return simple;
}

-(BOOL)isAnyTextFieldEmpty
{
    BOOL empty = NO;
    for (UITextField *textField in self.textFields)
    {
        if ([textField.text isEqualToString:@""])
        {
            empty = YES;
            break;
        }
    }
    
    return empty;
}

- (void)showCheckmarks:(NSArray *)checkmarkTypes withImage:(UIImage *)image
{
    for (UIImageView *imageView in self.checkmarks)
    {
        for (NSNumber *number in checkmarkTypes)
        {
            if (imageView.tag == [number integerValue])
            {
                imageView.alpha = 1.0;
                imageView.image = image;
            }
        }
        
    }
}

- (void)showGreetingForUser:(EcomapLoggedUser *)user
{
    [InfoActions showPopupWithMesssage:[NSString stringWithFormat:NSLocalizedString(@"Вітаємо, %@!", @"Welcome, {User Name}"), user.name]];
}

@end
