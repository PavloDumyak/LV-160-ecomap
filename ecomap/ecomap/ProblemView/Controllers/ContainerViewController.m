//
//  ContainerViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/18/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ContainerViewController.h"
#import "AddCommViewController.h"


@interface ContainerViewController ()

@property (nonatomic) NSUInteger currentIndex;
@property (weak, nonatomic) UIViewController *currentViewController;

@end

@implementation ContainerViewController


+ (NSArray *)availableSegues
{
    return @[
             @"DetailedView",
             @"ActivityView",
             @"CommentsView"
             ];
}

- (void)setProblemDetails:(EcomapProblemDetails *)problemDetails
{
    if ([self.currentViewController conformsToProtocol:@protocol(EcomapProblemDetailsHolder)])
    {
        [((id<EcomapProblemDetailsHolder>)self.currentViewController) setProblemDetails:problemDetails];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentIndex = [ContainerViewController availableSegues].count;
    [self showViewAtIndex:0];
}

- (void)showViewAtIndex:(NSUInteger)index
{
    if (self.currentIndex != index)
    {
        NSArray *segues = [ContainerViewController availableSegues];
        if (index < segues.count)
        {
            self.currentIndex = index;
            [self performSegueWithIdentifier:segues[index] sender:nil];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[ContainerViewController availableSegues] containsObject:segue.identifier])
    {
        if (self.childViewControllers.count > 0)
        {
            self.currentViewController = segue.destinationViewController;
            if ([segue.identifier isEqualToString:@"CommentsView"])
            {
                AddCommViewController *addComm = (AddCommViewController*)segue.destinationViewController;
                [addComm setProblem_ID:self.problem_id];
            }
            [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:segue.destinationViewController];
        }
        else
        {
            self.currentViewController = segue.destinationViewController;
            [self addChildViewController:segue.destinationViewController];
            ((UIViewController *)segue.destinationViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:((UIViewController *)segue.destinationViewController).view];
            [segue.destinationViewController didMoveToParentViewController:self];
        }
        
       
    }
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
    }];
}

@end
