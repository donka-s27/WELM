//
//  WelmAlertController.m
//  Welm
//
//  Created by Donka Stoyanov on 1/9/16.
//  Copyright © 2016 Donka Stoyanov. All rights reserved.
//

#import "WelmAlertController.h"

@interface WelmAlertController ()

@end

@implementation WelmAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    WelmAlertController* alert = [[WelmAlertController alloc] init];
    
    alert.title = title;
    alert.message = message;
    
    return alert;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIAlertControllerStyle)preferredStyle
{
    return UIAlertControllerStyleAlert;
}

@end
