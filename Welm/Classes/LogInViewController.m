//
//  LogInViewController.m
//  Welm
//
//  Created by Luke Stanley on 11/30/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "LogInViewController.h"
#import "KeyboardHelper.h"
#import "CommonUtils.h"
#import <SVProgressHUD.h>
#import <Parse/Parse.h>
#import "TwilioSMS.h"

@interface LogInViewController ()
{
    BOOL bInitLayout;
}

@property (nonatomic, strong) KeyboardHelper* kbHelper;

@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutLogoY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutControlHeight;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    bInitLayout = NO;
    self.kbHelper = [[KeyboardHelper alloc] initWithViewController:self onDoneSelector:@selector(onDone)];

    self.txtUsername.text = @"test";
    self.txtPassword.text = @"qqq";
}

- (void) onDone{
    [self.view endEditing:YES];
}


- (void) viewDidAppear:(BOOL)animated{

    [self.kbHelper enable];
}

- (void) viewWillDisappear:(BOOL)animated{
    [self.kbHelper disable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - layout

- (void)viewDidLayoutSubviews
{
    if(!bInitLayout)
    {
        bInitLayout = YES;
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat rate = screenSize.height / 600.0;
        
        self.layoutLogoY.constant = (CGRectGetMinY(self.txtUsername.frame) - CGRectGetHeight(self.logo.frame)) / 2;
        self.layoutControlHeight.constant = (int)(self.layoutControlHeight.constant * rate);
    }
}

- (IBAction)OnLogIn:(id)sender {
    
    if ( !self.txtUsername.text.length )
    {
        [CommonUtils showModalAlertWithTitle:@"Log In" description:@"Fill username"];
        return;
    }
    
    if ( !self.txtPassword.text.length )
    {
        [CommonUtils showModalAlertWithTitle:@"Log In" description:@"Fill password"];
        return;
    }
    
    [SVProgressHUD show];
    [PFUser logInWithUsernameInBackground:self.txtUsername.text password:self.txtPassword.text block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        
        if(error)
        {
            [CommonUtils showModalAlertWithTitle:@"Log In" description:error.localizedDescription];
        }
        else
        {
            [[CommonUtils sharedObject] loadGoogleInfo];
            [self performSegueWithIdentifier:@"LoginToStart" sender:nil];
        }
        
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - orientation

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
