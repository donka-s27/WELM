//
//  SignUpViewController.m
//  Welm
//
//  Created by Luke Stanley on 11/30/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "SignUpViewController.h"
#import "KeyboardHelper.h"
#import "CommonUtils.h"
#import <SVProgressHUD.h>
#import <Parse/Parse.h>


@interface SignUpViewController ()
{
    BOOL bInitLayout;
}

@property (nonatomic, strong) KeyboardHelper* kbHelper;


@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;

@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutLogoY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutControlHeight;
@end


@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    bInitLayout = NO;
    
    self.kbHelper = [[KeyboardHelper alloc] initWithViewController:self onDoneSelector:@selector(onDone)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Button Action

- (IBAction)OnBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)processVerification
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"13681032837" forKey:@"number"];
    [PFCloud callFunctionInBackground:@"inviteWithTwilio" withParameters:params block:^(id object, NSError *error) {
        NSString *message = @"";
        if (!error) {
            message = @"Your SMS invitation has been sent!";
        } else {
            message = @"Uh oh, something went wrong :(";
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Invite Sent!"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
    }];
}

- (IBAction)OnSignUp:(id)sender {
    
    if ( !self.txtUsername.text.length )
    {
        [CommonUtils showModalAlertWithTitle:@"Sign Up" description:@"Fill username"];
        return;
    }
    
    if ( self.txtPhoneNumber.text.length == 0 || self.txtEmail.text.length == 0 )
    {
        [CommonUtils showModalAlertWithTitle:@"Sign Up" description:@"Fill phone number, email address"];
        return;
    }
    
    if ( self.txtPassword.text.length == 0 || self.txtPassword.text.length == 0 )
    {
        [CommonUtils showModalAlertWithTitle:@"Sign Up" description:@"Fill password and confirm password"];
        return;
    }
    
    if ( ![self.txtPassword.text isEqualToString:self.txtConfirmPassword.text] )
    {
        [CommonUtils showModalAlertWithTitle:@"Sign Up" description:@"Fill password & confirm password"];
        return;
    }

    [SVProgressHUD show];
    
    NSString* strCode = [NSString stringWithFormat:@"%d", ABS(arc4random())];
    strCode = [strCode substringFromIndex:strCode.length - 6];
    NSLog(@"strCode = %@, ", strCode);
    
    PFUser *user = [PFUser user];
    user.username = self.txtUsername.text;
    
    user.password = self.txtPassword.text;
    user.email = self.txtEmail.text;
    user[@"phonenumber"] = self.txtPhoneNumber.text;
    user[@"verification"] = strCode;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

        [SVProgressHUD dismiss];

        if(error)
        {
            [CommonUtils showModalAlertWithTitle:@"Sign Up" description:error.localizedDescription];
        }
        else
        {
            [self OnBack:nil];
        }
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
