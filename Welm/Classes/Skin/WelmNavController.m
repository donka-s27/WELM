//
//  WelmNavController.m
//  Welm
//
//  Created by Donka Stoyanov on 11/26/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "WelmNavController.h"

@interface WelmNavController ()

@end

@implementation WelmNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController* visibleVC = [self visibleViewController];
    
    return [visibleVC supportedInterfaceOrientations];
}

@end
