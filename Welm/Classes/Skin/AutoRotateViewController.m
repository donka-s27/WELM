//
//  AutoRotateViewController.m
//  Welm
//
//  Created by Luke Stanley on 11/25/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "AutoRotateViewController.h"
#import "AppDelegate.h"
#import "WelmTabBarController.h"
#import "RecordViewController.h"
#import "CommonUtils.h"

@interface AutoRotateViewController ()
{
    UISwipeGestureRecognizer* _swipeLeftGesture;
    UISwipeGestureRecognizer* _swipeRightGesture;
    
    BOOL                        _autoRotate;
    UIInterfaceOrientationMask  _orientationMask;
}
@end

@implementation AutoRotateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    _swipeLeftGesture.numberOfTouchesRequired = 1;
    _swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    _swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    _swipeRightGesture.numberOfTouchesRequired = 1;
    _swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    topViewController = self;
    
    _autoRotate = NO;
    _orientationMask = UIInterfaceOrientationMaskPortrait;
    
//    CGSize size = [UIScreen mainScreen].bounds.size;
//    
//
//    if (size.width > size.height) {
//        
//        [self showRecordViewController];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view addGestureRecognizer:_swipeLeftGesture];
    [self.view addGestureRecognizer:_swipeRightGesture];
    
    [self performSelector:@selector(updateOrientaion) withObject:nil afterDelay:0.5];
}

- (void)updateOrientaion
{
    _autoRotate = YES;
    _orientationMask = UIInterfaceOrientationMaskAll;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.view removeGestureRecognizer:_swipeLeftGesture];
    [self.view removeGestureRecognizer:_swipeRightGesture];
}

- (BOOL)shouldAutorotate
{
    return _orientationMask;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return _orientationMask;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    if ( topViewController == self) {

        self.view.alpha = 0.0;
        UITabBar* tabBar = self.tabBarController ? self.tabBarController.tabBar : nil;
        
        if(tabBar)
            tabBar.alpha = 0.0;
        
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            
            if(size.width > size.height)
            {
                [self showRecordViewController];
                self.view.alpha = 1.0;
                if(tabBar)
                    tabBar.alpha = 1.0;
            }
        }];
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - utils

- (void)showRecordViewController
{
    RecordViewController  *recordVC = (RecordViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RecordViewController"];
    
    [self.navigationController pushViewController:recordVC animated:NO];
}

#pragma mark - swipe

- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController* nvc = (UINavigationController*)appDelegate.window.rootViewController;
    UIViewController* vc = nvc.topViewController;
    
    WelmTabBarController* tvc = nil;
    
    if([vc isKindOfClass:[WelmTabBarController class]])
        tvc = (WelmTabBarController*)vc;
    else if(vc.tabBarController)
        tvc = (WelmTabBarController*)(vc.tabBarController);

    if(!tvc)
        return;
    
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        [tvc moveToLeft];
    }
    else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        [tvc moveToRight];
    }
}

@end
