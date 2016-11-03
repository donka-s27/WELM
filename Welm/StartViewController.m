//
//  StartViewController.m
//  Welm
//
//  Created by Luke Stanley on 11/25/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "StartViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button action

- (IBAction)OnHome:(id)sender
{
    [self performSegueWithIdentifier:@"toHome" sender:nil];
}

@end
