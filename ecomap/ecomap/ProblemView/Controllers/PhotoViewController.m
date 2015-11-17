//
//  PhotoViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/24/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "PhotoViewController.h"
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "InfoActions.h"

@interface PhotoViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *imageDescriptions;
@property (nonatomic, strong) UITextView *messageBox;
@property(nonatomic, strong) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UILabel *maxPhotoLabel;

@end

@implementation PhotoViewController

static const NSInteger TextFieldsStartTag = 100;
static const NSUInteger DefaultMaxPhotos = 5;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.imageDescriptions = [NSMutableArray array];
    //Set gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpinside:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    if (self.maxPhotos == 0)
    {
        self.maxPhotos = DefaultMaxPhotos;
    }
}

- (void)setMaxPhotos:(NSUInteger)maxPhotos
{
    _maxPhotos = maxPhotos;
    [self updateUI];
}

- (void)updateUI
{
    self.maxPhotoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Ви можете додати ще %lu фото", @"You can add {numbeer} more photo"),
                               (unsigned long)(self.maxPhotos - self.imageDescriptions.count)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //setup keyboard notifications
    [self registerForKeyboardNotifications];
    [self updateUI];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.activeField resignFirstResponder];
    [self deregisterForKeyboardNotifications];
}

- (IBAction)galleryTap:(id)sender
{
    [self showImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)cameraTap:(id)sender
{
#if !(TARGET_IPHONE_SIMULATOR)
    [self showImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
#endif
}

- (BOOL)showImagePickerWithType:(UIImagePickerControllerSourceType)sourceType
{
    BOOL canAddPhotos = self.imageDescriptions.count < self.maxPhotos;
    if (canAddPhotos)
    {
        UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
        uiipc.delegate = self;
        uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
        uiipc.sourceType = sourceType;
        uiipc.allowsEditing = NO;
        [self presentViewController:uiipc animated:YES completion:NULL];
    }
    else
    {
        [InfoActions showAlertWithTitile:NSLocalizedString(@"Увага!", @"Attention!")
                              andMessage:[NSString stringWithFormat:NSLocalizedString(@"Ви можете додати не більше %lu фото", @"You can add maximum {number} photos"), (unsigned long)self.maxPhotos]];
    }
    return canAddPhotos;
}

- (IBAction)chooseTap:(id)sender
{
    [self touchUpinside:nil];
    [self.delegate photoViewControllerDidFinish:self withImageDescriptions:self.imageDescriptions];
}

- (IBAction)cancelTap:(id)sender
{
    [self touchUpinside:nil];
    [self.delegate photoViewControllerDidCancel:self];
}

#pragma mark - Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image)
    {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 640.0/480.0;
    
    if (imgRatio!=maxRatio)
    {
        if (imgRatio < maxRatio)
        {
            imgRatio = 480.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 480.0;
        }
        else
        {
            imgRatio = 640.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 640.0;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    EcomapLocalPhoto *descr = [[EcomapLocalPhoto alloc] initWithImage:img];
    [self.imageDescriptions addObject:descr];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.tableView reloadData];
    [self updateUI];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.imageDescriptions removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        [self updateUI];
    }
}

#pragma mark - Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageDescriptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    UITextField *descriptionText = nil;
    if ([cell.accessoryView isKindOfClass:[UITextField class]])
    {
        descriptionText = (UITextField*)cell.accessoryView;
    }
    else
    {
        descriptionText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width * 0.8, cell.contentView.frame.size.height)];
        descriptionText.adjustsFontSizeToFitWidth = NO;
        descriptionText.backgroundColor = [UIColor clearColor];
        descriptionText.autocorrectionType = UITextAutocorrectionTypeNo;
        descriptionText.autocapitalizationType = UITextAutocapitalizationTypeWords;
        descriptionText.textAlignment = NSTextAlignmentRight;
        descriptionText.keyboardType = UIKeyboardAppearanceDefault;
        descriptionText.returnKeyType = UIReturnKeyDone;
        descriptionText.clearButtonMode = UITextFieldViewModeNever;
        descriptionText.delegate = self;
        cell.accessoryView = descriptionText;
    }

    EcomapLocalPhoto *descr = self.imageDescriptions[indexPath.row];
    cell.imageView.image = descr.image;
    cell.accessoryType = UITableViewCellAccessoryNone;

    descriptionText.text = descr.imageDescription;
    descriptionText.placeholder = NSLocalizedString(@"Додати опис", @"Add description");
    descriptionText.tag = TextFieldsStartTag + indexPath.row;
    
    return cell;
}

#pragma mark - UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUInteger index = textField.tag - TextFieldsStartTag;
    if (index < self.imageDescriptions.count)
    {
        EcomapLocalPhoto *descr = self.imageDescriptions[index];
        descr.imageDescription = textField.text;
    }
    self.activeField = nil;
}

- (void)touchUpinside:(UITapGestureRecognizer *)sender
{
    [self.activeField resignFirstResponder];
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

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect contetntViewRect = self.activeField.superview.superview.frame;
    contetntViewRect.size.height += keyboardSize.height;
}

@end
