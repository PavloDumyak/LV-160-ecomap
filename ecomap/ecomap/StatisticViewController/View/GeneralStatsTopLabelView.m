//
//  GeneralStatsTopLabelView.m
//  ecomap
//
//  Created by ohuratc on 16.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "GeneralStatsTopLabelView.h"

#define TOP_LABEL_STANDART_HEIGHT 116
#define TOP_LABEL_NUMBER_FONT_SIZE 76
#define TOP_LABEL_NAME_FONT_SIZE 20
#define TOP_LABEL_OFFSET_FROM_TOP -8
#define TOP_LABEL_OFFSET_BETWEEN_NUMBER_AND_NAME -25

@implementation GeneralStatsTopLabelView

#pragma mark - Properties

- (void)setNumberOfInstances:(NSUInteger)numberOfInstances
{
    _numberOfInstances = numberOfInstances;
    [self setNeedsDisplay];
}

- (void)setNameOfInstances:(NSString *)nameOfInstances
{
    _nameOfInstances = nameOfInstances;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

// Helper methods to calculate sizes of fonts, offset, etc.

- (CGFloat)topLabelScaleFactor { return self.bounds.size.height / TOP_LABEL_STANDART_HEIGHT; }
- (CGFloat)numberFontSize { return TOP_LABEL_NUMBER_FONT_SIZE * [self topLabelScaleFactor]; }
- (CGFloat)nameFontSize { return TOP_LABEL_NAME_FONT_SIZE * [self topLabelScaleFactor]; }
- (CGFloat)offsetFromTop { return TOP_LABEL_OFFSET_FROM_TOP * [self topLabelScaleFactor]; }
- (CGFloat)offsetBetweenNumberAndName { return TOP_LABEL_OFFSET_BETWEEN_NUMBER_AND_NAME * [self topLabelScaleFactor]; }


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawLabel];
}

- (void)drawLabel
{
    // Drawing number of instances
    UIFont *numberFont = nil; // default font
    
    if ([UIFont fontWithName:@"OpenSans-Light" size:[self numberFontSize]])
    {
        numberFont = [UIFont fontWithName:@"OpenSans-Light" size:[self numberFontSize]];
    }
    else
    {
        numberFont = [UIFont fontWithName:@"Helvetica-Light" size:[self numberFontSize]];
    }
    
    NSAttributedString *numberText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", (unsigned long)self.numberOfInstances]
                                                                     attributes:@{ NSFontAttributeName : numberFont}];
    
    CGRect numberTextBounds;
    numberTextBounds.size = [numberText size];
    numberTextBounds.origin = CGPointMake((self.bounds.size.width - numberTextBounds.size.width) / 2, [self offsetFromTop]);
    
    if (self.numberOfInstances)
    { // Not drawing whith empty properties
        [numberText drawInRect:numberTextBounds];
    }
    // Drawing name of instances
    
    UIFont *nameFont = nil; // default font;
    
    if([UIFont fontWithName:@"OpenSans-Semibold" size:[self nameFontSize]])
    {
        nameFont = [UIFont fontWithName:@"OpenSans-Semibold" size:[self nameFontSize]];
    }
    else
    {
        nameFont = [UIFont fontWithName:@"Helvetica" size:[self nameFontSize]];
    }
    
    UIColor *fontColor = [UIColor lightGrayColor];
    NSAttributedString *nameText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.nameOfInstances]
                                                                   attributes:@{ NSFontAttributeName : nameFont,
                                                                                 NSForegroundColorAttributeName: fontColor}];
    
    CGRect nameTextBounds;
    nameTextBounds.size = [nameText size];
    nameTextBounds.origin = CGPointMake((self.bounds.size.width - nameTextBounds.size.width) / 2, numberTextBounds.size.height + [self offsetBetweenNumberAndName]);
    
    if (self.nameOfInstances)
    {
        // Not drawing whith empty properties
        [nameText drawInRect:nameTextBounds];
    }
}

#pragma mark - Initialization

- (void)setup
{
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        [self setup];
    }
    
    return self;
}

@end
